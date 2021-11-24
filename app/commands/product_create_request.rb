# frozen_string_literal: true

class ProductCreateRequest
  prepend SimpleCommand

  def initialize(current_user, parameters)
    @current_user = current_user
    @parameters = parameters
  end

  def call
    perform
  end

  private

  attr_reader :parameters, :current_user

  def perform
    values = parameters.require(:body).permit(:address, :description, :name, :price, :region_id, :latitude, :longitude, images: [], categorizations_attributes: [:category_id])
    new_record = current_user.products.new(values)
    if new_record.valid? && new_record.save
      new_record.id
    else
      '============= Product Errors =============='
      puts new_record.errors.inspect
      '==========================================='
      new_record.errors.full_messages
    end
  end
end
