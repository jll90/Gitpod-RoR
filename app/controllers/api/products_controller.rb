# frozen_string_literal: true

class Api::ProductsController < BaseApiController
  before_action :authenticate_request, except: :user_discover
  before_action :set_product, only: %i[archive update show_self]
  before_action :product_owner, only: %i[archive update show_self]

  def create
    # '============= Product Params =============='
    # puts params.inspect
    # '==========================================='
    new_record = ProductCreateRequest.call(current_user, params).result
    new_record.instance_of?(Array) ? json_error(new_record) : json_success({ product: new_record })
  rescue ActionController::ParameterMissing => e
    render_errors(e)
  end

  def update
    update_params = params.require(:body).permit(:address, :description, :name, :price, :region_id, :latitude, :longitude, images: [], to_delete_images: [:id], categorizations_attributes: [:category_id])

    @product.will_delete_image_ids = update_params[:to_delete_images]&.map { |p| p[:id].to_i }

    if @product.run_update(update_params)
      head :ok
    else
      json_error(@product, 422)
    end
  end

  def show
    render_product
  end

  def show_self
    render_product
  end

  def match_candidate_products
    match = Match.find_by(id: params[:match_id])

    return head :not_found unless match.present?
    return head :forbidden unless current_user.id == match.user_id

    render_products(match.buyer.products.active)
  end

  def user_discover
    ## manually authorizing in case a user is not logged in
    current_user = AuthorizeApiRequest.call(request.headers).result
    if current_user.present?
      render_products(current_user.discover_products)
    else
      render_products(Product.active.order(Arel.sql('RANDOM()')).limit(50))
    end
  end

  def user_products
    render_products(current_user.products.order("id DESC"))
  end

  def destroy
    success = ProductDeleteRequest.call(current_user, params).result
    success == true ? json_success : json_error(success)
  end

  def archive
    return head :bad_request unless @product.traded?
    return head :conflict if @product.archived?

    if @product.archive
      head :ok
    else
      head :internal_server_error
    end
  end

  if Rails.env.development?
    def reset
      success = ProductResetRequest.call(current_user, params).result
      success == true ? json_success : json_error(success)
    end
  end

  private

  def render_product
    json_success({ record: @product }, 200, { methods: %i[attachments active_categories] })
  end

  def set_product
    @product = Product.find(params[:id])
    return head :not_found unless @product.present?
  end

  def product_owner
    return head :forbidden unless @product.owned_by?(current_user)
  end

  def render_products(records, opts = { page: nil, per_page: nil })
    render json: RecordsPagination.call(records, opts[:page], opts[:per_page], { except: %i[user_id], methods: %i[attachments] }).result
  end
end
