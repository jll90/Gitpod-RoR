# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Landing Requests', type: :request do
  it 'works' do
    get '/'
    expect(response).to have_http_status(:ok)
  end
end

