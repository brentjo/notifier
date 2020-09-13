class SendEmailNotificationJob < ApplicationJob
  queue_as :default

  def perform(recipient, message)
    NotificationMailer.bare_email(recipient, message).deliver_now
  end
end
