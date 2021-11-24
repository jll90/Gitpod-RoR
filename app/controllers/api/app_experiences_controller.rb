class Api::AppExperiencesController < BaseApiController
  before_action :authenticate_request

  def create
    @app_experience = AppExperience.new(app_experience_params.merge({ user_id: current_user.id }))

    if @app_experience.save
      render :show, status: :created
    else
      render json: @app_experience.errors, status: :unprocessable_entity
    end
  end


  private
    def app_experience_params
      params.require(:body).permit(:name)
    end
end
