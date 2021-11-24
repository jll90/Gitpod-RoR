class UserDiscardProductRequest
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
    values = parameters.require(:body).permit(:id)
    ViewedProduct.create(user_id: current_user.id, product_id: values[:id])
  end
end
