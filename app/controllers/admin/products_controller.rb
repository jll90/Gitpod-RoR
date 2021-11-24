class Admin::ProductsController < ApplicationController
  before_action :retrieve_product, only: %i[show toggle_state remove_image]

  def index
    @products = Product.all.paginate(page: params[:page] || 1, per_page: Vars::PER_PAGE)
  end

  def show; end

  def toggle_state
    @product.send("#{params[:state]}!")
    render json: {}
  rescue StandardError
    render json: {}, status: 400
  end

  def remove_image
    image = @product.images.find(params[:image_id])
    image.destroy!
    raise 'Image not deleted' if image.persisted?

    render json: {}
  rescue StandardError
    render json: {}, status: 400
  end

  private

  def retrieve_product
    id = params[:id] || params[:product_id]
    @product = Product.find(id)
  end
end
