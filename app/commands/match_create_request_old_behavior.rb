# class MatchCreateRequest
#   prepend SimpleCommand

#   def initialize(current_user, parameters)
#     @current_user = current_user
#     @parameters = parameters
#   end

#   def call
#     perform
#   end

#   private

#   attr_reader :current_user, :parameters

#   def perform
#     values = parameters.require(:body).permit(:product, :product_buyer)
#     return false unless valid?(values)

#     match = Match.new(user_id: @product.user.id, product_id: @product.id,
#                       buyer_id: @buyer_product.user.id, buyer_product_id: @buyer_product.id)
#     if match.valid?
#       match.save
#     else
#       false
#     end
#   end

#   def valid?(values)
#     @product = Product.active.find_by(id: values[:product])
#     @buyer_product = current_user.products.active.find_by(id: values[:product_buyer])
#     @product.present? && @buyer_product.present? && (@buyer_product&.user&.id != @product&.user&.id)
#   end
# end
