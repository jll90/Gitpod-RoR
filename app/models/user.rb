# frozen_string_literal: true

class User < ApplicationRecord
  # include Loggable
  has_secure_password

  include Truekaso::Thumbnail

  has_many :update_requests
  has_many :products
  has_many :tokens
  has_many :matches, foreign_key: 'user_id', class_name: 'Match'
  has_many :buyer_matches, foreign_key: 'buyer_id', class_name: 'Match'
  has_many :viewed_products, through: :products
  has_many :devices_tokens
  has_many :swipes
  has_many :liked_swipes, -> { where(liked: true) }, class_name: 'Swipe'
  has_many :disliked_swipes, -> { where(liked: false) }, class_name: 'Swipe'
  has_many :asked_to_questions, foreign_key: 'addressee_id', class_name: 'Question'
  has_many :started_questions, foreign_key: 'user_id', class_name: 'Question'
  has_many :replies, dependent: :delete_all
  has_many :app_experiences

  has_one_attached :avatar_url

  validates :avatar_url, attached: true,
                     content_type: ['image/png', 'image/jpg', 'image/jpeg', 'image/webp'],
                     size: { less_than: 10.megabytes, message: 'must be less than 10MB in size' },
                     dimension: { width: { min: 100, max: 10_000 }, # max was 2400 and 1800
                                  height: { min: 100, max: 10_000 }, message: 'is not given between dimension' }, allow_blank: true
  
  # validates :email, presence: true, on: :create
  # validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :create
  # validates :email, uniqueness: true, on: :create
  # validates :phone, presence: true, on: :create
  # validates :password, length: { minimum: 6 }, on: :create

  validate :valid_number
  validates :username, format: { without: /\s/ }, uniqueness: { allow_nil: true }

  after_save :check_for_avatar_url

  def discover_products
    limit = Rails.env.development? ? 10 : 50
    # Product.where(region_id: 1).left_joins(:viewed_products).where('viewed_products.id' => nil)
    Product
      .active
      .where.not(id: excluded_products_ids)
      .where.not(user_id: id)
      .order(Arel.sql('RANDOM()'))
      .limit(limit)
  end

  # TODO: improve this query
  def excluded_products_ids
    # r1 = Match.where(buyer_id: id).select('product_id')
    Swipe.where(user_id: id).select('product_id')
    # result = r2.map(&:product_id) + r1.map(&:product_id)
  end

  def valid_number
    # success = /^(\+?56)?(\s?)(0?[123456789])(\s?)[9876543]\d{8}$/.match?(phone.to_s)
    success = Validations::PhoneNumber.validate phone.to_s
    errors.add(:phone, 'has invalid format') unless success
  end

  def avatar_attachment
    return unless self.avatar_url.attachment.present?

    {
      url: setup_url(self.avatar_url),
      thumbnails: [
        {size: '50x50', url: prepare_thumbnail(self.avatar_url, 50)},
        {size: '100x100', url: prepare_thumbnail(self.avatar_url, 100)},
        {size: '200x200', url: prepare_thumbnail(self.avatar_url, 200)}
      ]
    }
  end

  # TODO: implement mail
  def reset_password_instructions
    self.reset_password_token = BCrypt::Password.create(Time.now.to_i)
    self.reset_password_sent_at = Time.now
    save
  end

  # TODO: implement mail
  def reset_password(new_password)
    self.password = new_password.to_s
    self.reset_password_token = nil
    self.reset_password_sent_at = nil
    save
  end

  def save_login_code!(login_code)
    self.login_code = login_code
    self.login_code_sent_at = DateTime.now
    save
  end

  def clear_login_code!
    self.login_code = nil
    self.login_code_sent_at = nil
    save
  end

  def self.social_fields
    %i[username]
  end

  def self.sensitive_fields
    %i[password_digest updated_at login_code login_code_sent_at reset_password_token reset_password_sent_at avatar_url]
  end

  def self.contact_fields
    %i[phone email username]
  end

  def self.private_fields
    contact_fields(++ sensitive_fields)
  end

  def self.generate_phone
    "569#{rand(33333333..88888888)}"
  end

  def self.new_from_phone(phone_number)
    password = rand(1111111111..9999999999).to_s
    User.new(phone: phone_number, password: password, password_confirmation: password)
  end

  def self.f4023
    User.find_by phone: '56940234906'
  end

  def self.f7130
    User.find_by phone: '56971303317'
  end

  def self.f3015
    User.find_by phone: '56930158398'
  end

  def attach_test_image
    avatar_url.attach(
      io: File.open(Rails.root.join('spec', 'assets', 'test-product.webp')),
      filename: 'test-product.webp',
      content_type: 'image/webp'
    )
  end

  def self.thumbnail_host_url
    Product.thumbnail_host_url
  end

  def completed_onboarding?
    exp = AppExperience.find_by(user_id: self.id, name: AppExperience::ONBOARDING)
    exp.present?
  end

  private

  def check_for_avatar_url
    ActiveStorage::Current.host = User.thumbnail_host_url
    return unless self.avatar_url.attachment.present?

    if self.avatar_url_changed?
      unless Rails.env.test?
        CreateAvatarJob.perform_later(self.id)
      end
    end
  end

  def generate_auth_token
    tokens.create
  end
end
