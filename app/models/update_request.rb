class UpdateRequest < ApplicationRecord

  self.inheritance_column = :_type_disabled

  belongs_to :user

  EMAIL = 'email'.freeze
  PHONE = 'phone'.freeze

  VALID_TYPES = [EMAIL, PHONE].freeze

  validates :user_id, presence: true
  validates :old_value, presence: true
  validates :type, inclusion: { in: UpdateRequest::VALID_TYPES }
  validates :token, presence: true
  validates :code, presence: true

  after_initialize :on_init

  def on_init
    return unless self.new_record?

    self.expires_at = DateTime.now.utc + 5.minutes
    self.code = AuthenticationService.generate_login_code
    self.token = TokenGenerator.generate(128)
  end

  def self.find_latest_pending_request(user_id, search_value, type)
    update_requests = UpdateRequest.where(user_id: user_id).order('id DESC')
    return if update_requests.empty?

    matching_request = update_requests.find_by(token: search_value) || update_requests.find_by(code: search_value)

    return unless matching_request.present?
    return if matching_request.executed?
    return if matching_request.expired?

    matching_request.type == type ? matching_request : nil
  end

  def save_old_value(old_value)
    self.old_value = old_value
    self.save
  end

  def effect_update(new_value)
    return false if new_value.nil?

    self.new_value = new_value
    self.effected_at = DateTime.now.utc
    self.save
  end

  def self.sample_type
    UpdateRequest::VALID_TYPES.sample
  end

  def executed?
    self.effected_at.present? && self.new_value.present?
  end

  def expired?
    expiration_dt = self.expires_at
    expiration_dt.before?(DateTime.now.utc)
  end

end
