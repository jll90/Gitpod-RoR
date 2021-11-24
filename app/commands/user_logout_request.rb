class UserLogoutRequest
  prepend SimpleCommand

  def initialize(current_user, parameters)
    @current_user = current_user
    @parameters = parameters
  end

  def call
    perform
  end

  private

  attr_reader :current_user, :parameters

  def perform
    token = current_user.tokens.find_by(key: parameters[:id])
    return false if token.nil?

    token.destroy!
    !token.persisted?
  end
end
