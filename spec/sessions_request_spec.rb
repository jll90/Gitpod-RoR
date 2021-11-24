require 'rails_helper'

RSpec.describe "Session Requests", :type => :request do
  describe "Request Login Code" do
    it "creates a user on the fly when requesting code" do
      phone_number = "56912345612"
      expect(User.find_by(phone: phone_number)).to be_falsy
      post "/api/sessions/code.json?phone_number=#{phone_number}", headers: { 'Content-Type' => 'application/json'}
      expect(response.status).to eq 201
      expect(User.find_by(phone: phone_number)).to be_truthy
    end

    it "generates code for existing user" do
      user = create(:user)
      post "/api/sessions/code.json?phone_number=#{user.phone}", headers: { 'Content-Type' => 'application/json'}
      expect(response.status).to eq 201
    end
  end
end