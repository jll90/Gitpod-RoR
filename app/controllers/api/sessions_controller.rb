# frozen_string_literal: true
#
class Api::SessionsController < BaseApiController

  def request_login_code
    ## TODO can support emmails in the future
    phone_number = params[:phone_number]
    phone_user = User.find_by(phone: phone_number)

    if phone_user.nil?
      password = SecureRandom.hex
      phone_user = User.new(phone: phone_number, password: password)
      return json_error(phone_user.errors, 422) unless phone_user.save
    end

    login_code = AuthenticationService.generate_login_code()

    phone_user.save_login_code!(login_code)
    message = "Tu código Truekazo de acceso es #{login_code}. Si no has sido tú, ignora este mensaje."

    if ENV['TRUEKASO_SEND_SMS'] == 'true'
      SmsService.send(phone_number, message)
    end
    head :created
  end

  def validate_login_code
    phone_number = params[:phone_number]
    login_code = params[:login_code]

    user = User.find_by(phone: phone_number)

    return head :unauthorized unless user.present? && AuthenticationService.login_with_phone?(user, login_code)

    user.clear_login_code!

    token = user.tokens.create
    json_success({token: token.key, username: user.username, completed_onboarding: user.completed_onboarding?}, 201)
  end

end
