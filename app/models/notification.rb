class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :log

  ALLOWED = [
    'match_created',
    'match_updated',
    'product_created',
    'question_created',
    'reply_created'
  ]

  after_create :push_devices_notifications

  private

  def push_devices_notifications
    return if Rails.env.test?

    if user.devices_tokens.empty?
      puts "User doesn't have devices token. skip notification!" && return
    else
      user.devices_tokens.map do |device_token|
        method = "trigger_#{device_token.operating_system.downcase}_notification"
        method(method).call(device_token.token)
      end
    end
  end

  def trigger_ios_notification(token)
    # n = Rpush::Apns2::Notification.new
    # n.app = Rpush::Apns2::App.find_by_name(IOS_APP)
    # n.device_token = token # hex string
    # n.alert = self.to_json
    # n.data = {
    #   headers: { 'apns-topic': "BUNDLE ID" }, # the bundle id of the app, like com.example.appname. Not necessary if set on the app (see above)
    #   foo: :bar
    # }
    # n.save!
    puts "sending notification to ios device with token #{token}"
  end

  def trigger_android_notification(token)
    n = Rpush::Gcm::Notification.new
    n.app = Rpush::Gcm::App.find_by_name(ANDROID_APP)
    n.registration_ids = [token]
    n.data = {
      log: self.log.as_json({include: [:loggable]}),
      body: self.content,
      title: self.title
    }
    n.priority = 'high'        # Optional, can be either 'normal' or 'high'
    n.content_available = true # Optional
    # Optional notification payload. See the reference below for more keys you can use!
    n.notification = { body: self.content,
                       title: self.title
                     }
    n.save!
    puts "sending notification to android device with token #{token}"
  end

  class << self
    def prepare(log_record)
      body = case log_record.event
      when 'match_created'
        match = log_record.loggable
        {user_id: match.receiver.id, title: 'Nuevo like recibido', content: "Por el producto #{match.product.name}" }

      when 'match_updated'
        match = log_record.loggable
        payload = {}
        # puts "=========="
        # puts match.changes
        # puts match.just_accepted
        # puts match.just_transitioned_to_accepted?
        # puts match.just_confirmed
        # puts match.just_transitioned_to_confirmed?
        # puts "=========="
        if match.just_transitioned_to_accepted?
          payload = {user_id: match.sender.id, title: 'Truekaso iniciado!', content: "Solo falta que confirmes!" }
        end

        if match.just_transitioned_to_confirmed?
          payload = {user_id: match.received.id, title: 'Truekaso completado!', content: "Felicitaciones. Ponte en contacto!" }
        end
        payload
      when 'question_created'
        question = log_record.loggable
        {user_id: question.product.owner.id, title: 'Te han hecho una pregunta', content: "#{question.content}" }
      when 'reply_created'
        reply = log_record.loggable
        question = reply.question

        ## don't do anything for first reply
        return if question.replies.count < 2
        ## only notify if important people are answering
        return unless question.is_main_member?(reply.user_id)

        user_id = question.get_other_party(reply.user_id)
        {user_id: user_id, title: 'Te respondieron', content: "#{reply.content}" }
      else
        {}
      end
      # puts body.inspect
      create(body.merge(log_id: log_record.id)) if body.any?
    end
  end

end
