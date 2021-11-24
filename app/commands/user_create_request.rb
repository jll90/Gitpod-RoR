class UserCreateRequest
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
    values = parameters.require(:body).permit(:phone, :email, :password)
    @user = User.new(phone: values[:phone], email: values[:email], password: values[:password].to_s)
    if @user.valid? && @user.save
      @user.tokens.last.key
    else
      @user.errors.full_messages
    end
  end
end
