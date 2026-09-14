class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "hello@appnea.test")
  layout "mailer"
end
