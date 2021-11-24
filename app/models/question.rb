class Question < ApplicationRecord
  include Loggable

  belongs_to :product
  belongs_to :user
  belongs_to :addressee, class_name: 'User'
  ## must add table name for default ordering
  ## https://github.com/rails/rails/issues/42552
  has_many :replies, -> { includes(:reply_receipts).order('replies.id ASC') }, dependent: :delete_all
  has_many :reply_receipts, through: :replies
  # doesnt work
  # apparently the order is misinterpreted and this wrecks everything
  # https://stackoverflow.com/questions/15824041/rails-associations-has-one-latest-record
  # might consideu trying something like this in the future
  # has_one :latest_reply, -> { order('id DESC').limit(1) }, class_name: 'Reply'

  validates :user_id, :content, presence: true

  after_create :clone_question_as_reply

  attr_accessor :current_user_id
  # after_create :queue_notifications

  def latest_reply
    self.replies.last
  end

  def reply_count
    self.replies.count
  end

  def is_main_member?(user_id)
    self.user_id == user_id || self.addressee_id == user_id
  end

  def get_other_party(user_id)
    return self.addressee_id if self.user_id == user_id
    return self.user_id if self.addressee_id == user_id

    nil
  end

  def members(reject_user_ids = [])
    user_ids = self.replies.pluck(:user_id).uniq
    user_ids = (user_ids.include? product.owner.id) ? user_ids : user_ids.concat([product.owner.id])

    User.where(id: user_ids)
  end

  def is_participant?(user_id)
    self.members.ids.include? user_id
  end

  def as_notification_json
    self.as_json
  end

  def mark_as_read(user_id)
    raise ArgumentError.new("Non members cannot mark question as read, User ID: #{user_id}") unless self.is_participant?(user_id)

    user_reply_receipts = self.reply_receipts.select { |rr| rr.user_id == user_id }

    ## should probably do some sort of update_all for improved performance
    user_reply_receipts.map(&:mark_as_read)
  end

  def self.seed!
    products = Product.all
    users = User.all
    
    products.each do |p|
      next if p.id % 3 != 0
      user = (users - [p.owner]).sample

      p.questions.create!(
        user_id: user.id, 
        addressee_id: p.owner.id,
        content: 
        Faker::Lorem.sentence
      )
    end
  end

  private

  def clone_question_as_reply # hack to reference user_replies
    reply = replies.new(content: self.content, user_id: self.user_id)
    reply.save!
  end

end
