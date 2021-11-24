require 'rails_helper'

RSpec.describe "Health checks", :type => :request do
  it "works" do
    get "/healthz"
    expect(response).to have_http_status(:ok)
  end
end