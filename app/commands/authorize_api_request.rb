class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(headers = {})
    @headers = headers
  end

  def call
    perform
  end

  private

  attr_reader :headers

  def perform
    user = Token.find_by(key: http_auth_header).try(:user)
    @user ||= User.find(user.id) if user
    @user || errors.add(:token, 'Invalid token') && nil
  end

  def http_auth_header
    return headers['Authorization'].split('Bearer ').last if headers['Authorization'].present?

    errors.add(:token, 'Missing token')

    nil
  end
end
