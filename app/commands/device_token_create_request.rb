class DeviceTokenCreateRequest
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
    values = parameters.require(:body).permit(:operating_system, :token, :device_uniq_id)
    DevicesToken.upsert(values[:device_uniq_id], current_user.id, values[:operating_system], values[:token])
  end
end
