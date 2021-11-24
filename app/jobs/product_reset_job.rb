class ProductResetJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    record = Product.find(product_id)
    record.matches.each(&:reset!)
    record.categorizations.each(&:reset!)
  end
end
