class Log < ApplicationRecord
  belongs_to :loggable, polymorphic: true, optional: true
  has_many :notifications

  after_create :save_notifications, if: :must_be_notified?

  private

  def must_be_notified?
    Notification::ALLOWED.include?(self.event)
  end

  def save_notifications
    Notification.prepare(self)
  end
end