require 'rails_helper'

RSpec.describe "Reply Requests", :type => :request do
  describe "Reply creation" do
    it "can create a reply" do
      question = create(:question)
      token = create(:token)

      params = { 
        body: {
          content: 'contentful'
        }
      }

      url = "/api/questions/#{question.id}/replies.json"
      post url, params: params.to_json, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 201
    end
  end

  describe "Reply indexing" do
    it "user can list his own replies" do
      reply = create(:reply)
      token = create(:token, user: reply.user)

      url = "/api/replies.json"
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 200
      records = JSON.parse(response.body)["records"]
      expect(records).to be_an_instance_of(Array)
    end
  end
end