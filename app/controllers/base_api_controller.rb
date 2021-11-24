class BaseApiController < ActionController::API
  include ActiveStorage::SetCurrent

  before_action :verify_format
  attr_reader :current_user

  def verify_format
    head :bad_request unless request.format.json?
  end

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end

  def json_error(object = [], status = 422)
    render json: { error: object }, status: status
  end

  def json_success(object = {}, status = 200, opts = {})
    render json: object.as_json(opts), status: status
  end

  def render_errors(error)
    json_error = { error: 'missing parameters' }
    json_error.merge!(full_message: error) if Rails.env.development?

    render json: json_error, status: 422
  end
end
