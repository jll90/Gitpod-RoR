require 'rails_helper'

RSpec.describe UpdateRequest, type: :model do
  context "Pending Requests" do
    it "returns nil if expired?" do
      request = create(:update_request)
      result = UpdateRequest.find_latest_pending_request(request.user.id, request.token, request.type)
      expect(result).to be_truthy

      request.update(expires_at: DateTime.now.utc - 1.minutes)
      result = UpdateRequest.find_latest_pending_request(request.user.id, request.token, request.type)
      expect(result).to be_falsey
    end

    it "returns nil if executed?" do
      request = create(:update_request)
      result = UpdateRequest.find_latest_pending_request(request.user.id, request.token, request.type)
      expect(result).to be_truthy

      request.effect_update('foobar')
      result = UpdateRequest.find_latest_pending_request(request.user.id, request.token, request.type)
      expect(result).to be_falsey
    end

    it "returns only latest pending request" do
      request_one = create(:update_request)
      user = request_one.user
      type = request_one.type
      search_value = [request_one.code, request_one.token].sample
      
      result = UpdateRequest.find_latest_pending_request(user.id, search_value, type)
      expect(result).to be_truthy
      expect(result.id).to eq(request_one.id)

      request_two = create(:update_request, user: user, type: type)
      search_value = [request_two.code, request_two.token].sample

      result = UpdateRequest.find_latest_pending_request(user.id, search_value, type)
      expect(result).to be_truthy
      expect(result.id).to eq(request_two.id)
    end
  end

  context "Validation" do
    it "it is valid with an old value, type" do
      user = create(:user)
      update_request = UpdateRequest.new(type: 'email', old_value: 'foobar@gmail.com', user_id: user.id)
      expect(update_request.valid?).to eq(true)
    end
  end

  context "Expiration" do
    it "can be asked whether it has expired" do
      update_request = UpdateRequest.new
      expect(update_request.expired?).to eq(false)

      update_request.expires_at = DateTime.now.utc - 10.seconds
      expect(update_request.expired?).to eq(true)
    end
  end

  context "Initialization" do
    it "initializes values correctly" do
      update_request = UpdateRequest.new
      expect(update_request.expires_at).to be_truthy
      expect(update_request.code).to be_truthy
      expect(update_request.token).to be_truthy
    end
  end
end
