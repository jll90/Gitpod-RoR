class UserForgotPasswordRequest
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
    values = parameters.require(:body).permit(:email)
    User.find_by(email: values[:email].to_s)&.reset_password_instructions
  end
end
