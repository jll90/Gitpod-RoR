require 'rails_helper'

RSpec.describe "Question Requests", :type => :request do
  describe "Question creation" do
    it "can create a question" do
      product = create(:product)
      token = create(:token)

      params = { 
        body: {
          content: 'contentful'
        }
      }

      url = "/api/products/#{product.id}/questions.json"
      post url, params: params.to_json, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 201
    end
  end

  describe "Question indexing" do
    it "can index a user's question" do
      question = create(:question)
      token = create(:token, user: question.user)

      url = "/api/questions/self.json"
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 200
    end

    it "can index a product's question" do
      question = create(:question)

      url = "/api/products/#{question.product.id}/questions.json"
      get url, headers: RequestsHelpers.build_headers
      expect(response.status).to eq 200
    end

    it "can index a single question" do
      question = create(:question)

      url = "/api/questions/#{question.id}.json"
      get url, headers: RequestsHelpers.build_headers
      expect(response.status).to eq 200
    end
  end

  describe "Question mark as read" do
    it "returns not found for non-existent question" do
      token = create(:token)

      url = "/api/questions/321383/read.json"
      patch url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 404
    end

    it "returns forbidden if not among question members" do
      question = create(:question)
      token = create(:token)

      url = "/api/questions/#{question.id}/read.json"
      patch url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 403
    end

    it "returns no-content when marking as read" do
      question = create(:question)
      token = create(:token, user: question.user)

      url = "/api/questions/#{question.id}/read.json"
      patch url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 204
    end
  end
end
