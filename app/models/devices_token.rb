class DevicesToken < ApplicationRecord
  belongs_to :user

  validates :operating_system, presence: true
  validates :token, presence: true
  validates :device_uniq_id, presence: true
  ## prefers lowercase b/c react-native exports os like so
  validates :operating_system, inclusion: { in: %w(android ios) }

  def self.upsert(device_uniq_id, user_id, os, token)
    dts = DevicesToken.where(user_id: user_id, device_uniq_id: device_uniq_id)
    
    if dts.length == 0
      return DevicesToken.create_from_params(device_uniq_id, user_id, os, token)
    end

    if dts.length == 1
      device_token = dts.first
      device_token.update(token: token) 
      return device_token
    end

    dts.destroy_all
    DevicesToken.create_from_params(device_uniq_id, user_id, os, token)
  end

  def self.create_from_params(device_uniq_id, user_id, os, token)
    DevicesToken.create(token: token, user_id: user_id, operating_system: os, device_uniq_id: device_uniq_id)
  end
end
