require "rails_helper"

RSpec.describe Api::UpdateRequestsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/api/update_requests").to route_to("api/update_requests#create")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/api/update_requests/1").to route_to("api/update_requests#update", id: "1")
    end
  end
end
