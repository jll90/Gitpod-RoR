class UserEditRequest
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
    values = parameters.require(:body).permit(:email, :username, :avatar)

    current_user.email = values[:email] if values[:email].present?
    current_user.username = values[:username] if values[:username].present?
    current_user.avatar_url = values[:avatar] if values[:avatar].present?
    if current_user.valid? && current_user.save
      true
    else
      current_user.errors.full_messages
    end
  end
end
