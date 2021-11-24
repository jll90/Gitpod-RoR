# frozen_string_literal: true

class Api::ApiController < ActionController::API
  def health
    render json: { result: 'success', data: nil }
  end
end
