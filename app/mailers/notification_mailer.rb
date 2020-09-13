class NotificationMailer < ApplicationMailer

  def bare_email(recipient, message)
    @message = message
    mail(to: recipient, subject: 'NotifierAPI')
  end

end
