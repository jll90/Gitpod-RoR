class UserResetPasswordRequest
  prepend SimpleCommand

  def initialize(parameters)
    @parameters = parameters
  end

  def call
    perform
  end

  private

  attr_reader :parameters

  def perform
    values = parameters.require(:body).permit(:token, :password)
    User.find_by(reset_password_token: values[:token].to_s)&.reset_password(values[:password])
  end
end
