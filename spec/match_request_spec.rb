require 'rails_helper'

RSpec.describe "Match Requests", :type => :request do
  describe "Match show" do
    it "returns 403 if user has no relation to match" do
      match = create(:match)
      token = create(:token)

      url = "/api/matches/#{match.id}.json"
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 403
    end

    it "returns 200 for members" do
      match = create(:match)
      token = create(:token, user: match.user)

      url = "/api/matches/#{match.id}.json"
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 200

      token = create(:token, user: match.buyer)
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 200
    end
  end

  describe "Match unlocking" do
    it "returns 403 if user has no relation to match" do
      match = create(:match)
      token = create(:token)

      url = "/api/matches/#{match.id}/unlock.json"
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 403
    end

    it "returns 400 if match not confirmed" do
      match = create(:match)
      token = create(:token, user: match.user)

      url = "/api/matches/#{match.id}/unlock.json"
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 400
    end

    it "returns 200 for members and confirmed state" do
      match = create(:match)
      token = create(:token, user: match.user)

      match.update(state: 'confirmed') ## leaky abstraction

      url = "/api/matches/#{match.id}/unlock.json"
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 200

      token = create(:token, user: match.buyer)
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 200
    end
  end
end
