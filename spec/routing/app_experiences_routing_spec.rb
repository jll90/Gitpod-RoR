require "rails_helper"

RSpec.describe Api::AppExperiencesController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/api/app_experiences").to route_to("api/app_experiences#create")
    end

    # it "routes to #show" do
    #   expect(get: "/app_experiences/1").to route_to("app_experiences#show", id: "1")
    # end
  end
end
