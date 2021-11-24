class MatchCreateRequest
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
    values = parameters.require(:body).permit(:product)
    return false unless valid?(values)

    if match.valid?
      match.save
    else
      false
    end
  end

  def valid?(values)
    @product = Product.active.find_by(id: values[:product])
    @product.present? && (@product.user.id != current_user.id)
  end
end
