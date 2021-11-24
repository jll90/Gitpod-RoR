class Api::ProfilesController < BaseApiController

  before_action :authenticate_request

  def own_profile
    render json: { 
      record: current_user.as_json({ except: User.sensitive_fields, methods: %[avatar_attachment] }) 
    }
  end
end
