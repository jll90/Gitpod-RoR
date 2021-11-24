class SmsService
  def self.send(phone_number, message)
    api_key = ENV['TRUEKASO_SMS_SERVICE_API_KEY']
    base_uri = 'https://xr1klg.api.infobip.com'
    url = "#{base_uri}/sms/2/text/advanced"

    HTTParty.post(url, {
                    headers: {
                      'Authorization': "App #{api_key}",
                      'Content-Type': 'application/json'
                    },
                    body: build_sms_body(phone_number, message).to_json
                  })
  end

  def self.build_sms_body(phone_number, message)
    {
      messages: [
        {
          from: 'InfoSMS',
          destinations: [
            {
              to: phone_number.to_s
            }
          ],
          text: message
        }
      ]
    }
  end
end
