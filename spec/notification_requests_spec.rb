require 'rails_helper'

RSpec.describe "Notification Requests", :type => :request do
  describe "Get unread count" do
    it "can fetch unread tally" do
      token = create(:token)
      question = create(:question)
      create(:reply, user: token.user)

      url = "/api/notifications/unread.json"
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 200
    end
  end
end