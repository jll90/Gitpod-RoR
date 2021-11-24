class UserAuthenticateRequest
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
    values = parameters.require(:body).permit(:email, :password)
    user = User.find_by(email: values[:email].downcase)
    if user&.authenticate(values[:password])
      user.tokens.last.key
    else
      ['Incorrect email or password, try again.']
    end
  end
end
