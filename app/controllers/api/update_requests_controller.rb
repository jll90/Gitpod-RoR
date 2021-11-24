class Api::UpdateRequestsController < BaseApiController
  before_action :authenticate_request
  before_action :validate_request_type
  before_action :set_update_request, only: %i[update]

  def create
    creation_params = update_request_params.merge({ user_id: current_user.id, old_value: current_user.phone })
    @update_request = UpdateRequest.new(creation_params)

    if @update_request.save
      message = "Tu código Truekazo de actualización es #{@update_request.code}. Si no has sido tú, ignora este mensaje."

      SmsService.send(current_user.phone, message) if ENV['TRUEKASO_SEND_SMS'] == 'true'

      render :show, status: :created
    else
      render json: @update_request.errors, status: :unprocessable_entity
    end
  end

  def update
    return head :not_found if @update_request.nil?

    new_value = @update_params[:new_value]
    phone_user = User.find_by(phone: new_value)
    return head :conflict if phone_user.present?

    if @update_request.effect_update(new_value)
      @update_request.user.update(phone: new_value) if @update_params[:type] == UpdateRequest::PHONE
      render :show, status: :ok
    else
      render json: @update_request.errors, status: :unprocessable_entity
    end
  end

  private

  def validate_request_type
    return head :bad_request unless update_request_params[:type] == UpdateRequest::PHONE
  end

  def set_update_request
    @update_params = update_request_params
    @update_request = UpdateRequest.find_latest_pending_request(current_user.id, params[:id], @update_params[:type])
  end

  def update_request_params
    params.require(:body).permit(:type, :new_value)
  end
end
