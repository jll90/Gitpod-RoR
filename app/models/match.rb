# frozen_string_literal: true

class Match < ApplicationRecord
  include Loggable
  include AASM

  VALID_STATES = %i[pending accepted declined finished withdrawn confirmed dependency_deleted disqualified].freeze
  VALID_TRANSITIONS = %i[accept decline finish withdraw confirm disqualify delete_dependency disqualify].freeze

  belongs_to :user, class_name: 'User'
  belongs_to :product, class_name: 'Product'
  belongs_to :buyer, class_name: 'User', optional: true
  belongs_to :buyer_product, class_name: 'Product', optional: true

  after_initialize :on_init

  validates :user_id, uniqueness: { scope: %i[product_id buyer_id buyer_product_id] }
  validates :user_read, inclusion: { in: [ true, false ] }
  validates :buyer_read, inclusion: { in: [ true, false ] }

  scope :pending, -> { where(state: 'pending') }
  scope :accepted, -> { where(state: 'accepted') }
  scope :confirmed, -> { where(state: 'confirmed') }
  scope :withdrawn, -> { where(state: 'withdrawn') }
  scope :declined, -> { where(state: 'declined') }
  scope :finished, -> { where(state: 'finished') }
  scope :dependency_deleted, -> { where(state: 'dependency_deleted') }
  scope :disqualify, -> { where(state: 'disqualify') }

  aasm column: :state do
    state :pending, initial: true
    state :accepted
    state :confirmed
    state :declined
    state :withdrawn
    state :finished
    state :deleted
    state :dependency_deleted
    state :disqualified

    event :accept, after: proc { |*args| set_buyer_product(*args); handle_acceptance } do
      transitions from: :pending, to: :accepted
    end

    event :confirm, after: :handle_confirmation do
      transitions from: :accepted, to: :confirmed
    end

    event :decline do
      transitions from: :pending, to: :declined
    end

    event :withdraw do
      transitions from: :accepted, to: :withdrawn
    end

    event :finish do
      transitions from: :accepted, to: :finished
    end

    # if Rails.env.development?
    event :reset do
      transitions to: :pending, after: :reset_buyer_product
    end
    # end

    event :delete do
      transitions from: %i[pending accepted confirmed declined withdrawn finished], to: :deleted
    end

    event :delete_dependency do
      transitions to: :dependency_deleted
    end

    event :disqualify do
      transitions to: :disqualified
    end
  end

  attr_accessor :just_accepted
  attr_accessor :just_confirmed

  def on_init
    return unless self.new_record?

    self.user_read = false
    self.buyer_read = true
  end

  def reset_buyer_product
    self.buyer_product_id = nil
    save
  end

  def owned_by?(user)
    user_id == user.id || buyer_id == user.id
  end

  def just_transitioned_to_accepted?
    self.just_accepted == true
  end

  def just_transitioned_to_confirmed?
    self.just_confirmed == true
  end

  def self.generate_from_users!(u1, u2)
    Match.create!(
      buyer_id: u1.id,
      buyer_read: false,
      product_id: u2.products.sample.id, 
      user_id: u2.id, 
      user_read: false
    )
  end

  def self.seed!
    users = User.all

    (1..50).each do |_n|
      user = users.sample
      remaining_users = users - [users]
      other_user = remaining_users.sample
      Match.generate_from_users!(user, other_user)
    end
  end

  def products
    {
      owner: product.as_json(methods: %i[attachments]),
      buyer: buyer_product.as_json(methods: %i[attachments])
    }
  end

  def set_buyer_product(*args)
    self.buyer_product_id = args.first
    save
  end

  def handle_acceptance
    self.just_accepted = true
    self.buyer_read = false
    self.save
  end

  def handle_confirmation
    product_matches = Match.where_product_is_member(product_id).where.not(id: id)
    buyer_product_matches = Match.where_product_is_member(buyer_product_id).where.not(id: id)

    [product_matches, buyer_product_matches].each do |matches|
      Match.update_competing_matches(matches)
    end

    self.just_confirmed = true
    self.user_read = false
    self.save

    product.trade!
    buyer_product.trade!
  end

  def products_tradeable?
    buyer_product.tradeable? && product.tradeable?
  end

  def self.update_competing_matches(matches_list)
    matches = matches_list.uniq(&:id)

    matches.map do |match|
      if match.buyer_product_id.present? && match.state != 'disqualified'
        match.disqualify!
      else
        ## same user should destroy
        ## else would probably not destroy
        ## match.destroy
      end
      ## for the moment being
      ## there is no else branch
      ## becuase buyer_product_id means that
      ## the user can still choose a product
      ## and continue the flow - no harm done
    end
  end

  def self.where_product_is_member(product_id)
    Match.where(product_id: product_id).or(Match.where(buyer_product_id: product_id))
  end

  def sender 
    buyer
  end

  def receiver
    user
  end

  def receiver_product
    product
  end

  def sender_product
    buyer_product
  end
end
