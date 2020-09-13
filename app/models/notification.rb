class Notification < ApplicationRecord

  MAX_NOTIFICATIONS = 10

  belongs_to :user
  before_create :set_default_attributes

  validate :owner_under_notifications_limit

  def send_notification(message = nil)
    unless RateLimiter.allowed?(:send_message, "send_message:#{user.id}")
      return false
    end

    body = if message.present?
      message
    elsif default_message.present?
      default_message
    else
      "Alert from NotifierAPI. No custom message was specified."
    end

    SendEmailNotificationJob.perform_later(self.email, body)
    update_stats

    return true
  end

  private

  def set_default_attributes
   self.token = SecureRandom.hex(16)
   self.total_sent = 0
  end

  def update_stats
    self.update_attribute(:last_sent, DateTime.now)
    self.update_attribute(:total_sent, self.total_sent + 1)
  end

  def owner_under_notifications_limit
    if user.notifications.count >= MAX_NOTIFICATIONS
      errors.add(:users, "can't have more than #{MAX_NOTIFICATIONS} notifications")
    end
  end
end
