require 'rails_helper'

RSpec.describe "Notification Tokens Requests", :type => :request do
  describe "Posting token" do
    it "fails if unauthorized" do
      put "/api/notification_tokens.json", headers: RequestsHelpers.build_headers('')
      expect(response.status).to eq 401
    end

    it "fails for no data" do
      token = create(:token)
      put "/api/notification_tokens.json", headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 422
    end

    it "fails for invalid OS" do
      token = create(:token)
      put "/api/notification_tokens.json", params: build_data('foobar', 'foobar'), headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 422
    end

    it "fails if token is empty" do
      token = create(:token)
      put "/api/notification_tokens.json", params: build_data('android', ''), headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 422
    end

    it "succeeds if valid" do
      token = create(:token)
      os = ['android', 'ios'].sample
      put "/api/notification_tokens.json", params: build_data(os, 'nice-token'), headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 201
    end
  end

  def build_data(os, token)
    { 
      body: { 
        operating_system: os, 
        token: token,
        device_uniq_id: 'foobar'
      } 
    }.to_json
  end
end