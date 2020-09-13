class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@notifierapi.herokuapp.com'
  layout 'mailer'
end
