# frozen_string_literal: true

# TODO: verify status for creations, updates and deletions
class Api::ApiController < BaseApiController
  UNPROTECTED_ENDPOINTS = %i[login signup forgot_password reset_password products pending_matches].freeze
  VERIFY_MATCH_STATE = %i[user_matches user_requested_matches match_toggle_state].freeze
  before_action :authenticate_request, except: UNPROTECTED_ENDPOINTS
  before_action :verify_state_parameter, only: VERIFY_MATCH_STATE

  ################################################
  ##################### GET ######################
  ################################################

  if Rails.env.development?
    def discover
      render_discover(Product.all)
    end

    def products
      render_products(Product.all)
    end

    def matches
      render_matches(Match.all)
    end
  end

  ################################################
  ##################### PUT ######################
  ################################################

  def edit_user
    new_record = UserEditRequest.call(current_user, params).result
    new_record == true ? json_success : json_error(new_record)
  rescue ActionController::ParameterMissing => e
    render_errors(e)
  end

  def forgot_password
    UserForgotPasswordRequest.call(params).result
    json_success
  rescue ActionController::ParameterMissing => e
    render_errors(e)
  end

  def reset_password
    result = UserResetPasswordRequest.call(params).result
    result == true ? json_success : json_error
  rescue ActionController::ParameterMissing => e
    render_errors(e)
  end

  ################################################
  ##################### POST #####################
  ################################################

  def signup
    new_record = UserCreateRequest.call(params).result
    new_record.instance_of?(Array) ? json_error(new_record) : json_success({ token: new_record })
  rescue ActionController::ParameterMissing => e
    render_errors(e)
  end

  def login
    record = UserAuthenticateRequest.call(params).result
    record.instance_of?(Array) ? json_error(record, 401) : json_success({ token: record })
  rescue ActionController::ParameterMissing => e
    render_errors(e)
  end

  def discard_discovered_product
    UserDiscardProductRequest.call(current_user, params).result
    json_success
  rescue ActionController::ParameterMissing => e
    render_errors(e)
  end

  def device_token
    r = DeviceTokenCreateRequest.call(current_user, params).result
    r.valid? ? json_success({}, :created) : json_error(r.errors)
  rescue ActionController::ParameterMissing => e
    render_errors(e)
  end

  ##################################################
  ##################### DELETE #####################
  ##################################################

  def logout
    success = UserLogoutRequest.call(current_user, params).result
    success == true ? json_success : json_error
  end
end
