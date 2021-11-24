require 'rails_helper'

RSpec.describe "/update_requests", type: :request do
  describe "POST /create" do
    context "with valid parameters" do
      it "returns 401" do
        post api_update_requests_url, params: { body: { type: UpdateRequest::PHONE } }, headers: RequestsHelpers.build_headers, as: :json
        expect(response.status).to eq 401
      end

      it "creates a new UpdateRequest" do
        token = create(:token)

        expect {
          post api_update_requests_url,
          params: { body: { type: UpdateRequest::PHONE } }, headers: RequestsHelpers.build_headers(token.key), as: :json
        }.to change(UpdateRequest, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      it "does not create a new UpdateRequest" do
        token = create(:token)

        expect {
          post api_update_requests_url,
          params: { body: { type: nil } }, headers: RequestsHelpers.build_headers(token.key), as: :json
        }.to change(UpdateRequest, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "returns 401 if unauthorized" do
        update_request = create(:update_request)
        patch api_update_request_url(update_request.code), params: nil, headers: RequestsHelpers.build_headers, as: :json
        expect(response.status).to eq 401
      end

      it "succeeds" do
        update_request = create(:update_request)
        token = create(:token, user: update_request.user)

        patch api_update_request_url(update_request.code),
          params: {body: { new_value: User.generate_phone, type: UpdateRequest::PHONE }}, headers: RequestsHelpers.build_headers(token.key), as: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the update_request" do
        update_request = create(:update_request)
        token = create(:token, user: update_request.user)

        patch api_update_request_url(update_request.code),
          params: { body: { new_value: nil, type: UpdateRequest::PHONE } }, headers: RequestsHelpers.build_headers(token.key), as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
