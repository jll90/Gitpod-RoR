class Api::SwipesController < BaseApiController
  before_action :authenticate_request

  def upsert
    product = Product.find(params[:product_id])
    return head :bad_request unless product.present? && product.can_swipe_from?(current_user.id)

    liked = ActiveModel::Type::Boolean.new.cast(params[:liked])
    swipe = Swipe.upsert(current_user.id, product, liked) 

    if swipe
      head :created
    else
      head :internal_server_error
    end
  end
  
  def destroy_dislikes
    current_user.disliked_swipes.destroy_all
    head :ok
  end

  def index_self
    do_index(current_user.id)
  end

  def do_index(user_id)
    if user_id
      render_swipes Swipe.where(user_id: user_id).order("id DESC")
    else
      render_swipes Swipe.all
    end
  end

  def render_swipes(records)
    render json: RecordsPagination.call(records, params[:page], params[:per_page] || 100, {}).result
  end

end
