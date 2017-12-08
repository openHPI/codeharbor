class ApplicationMailer < ActionMailer::Base
  default from: "admin@codeharbor.com"
  layout 'mailer'
end
