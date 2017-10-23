class ApplicationMailer < ActionMailer::Base
  default :from => "codeharbor@openhpi.de"
  default "Precedence" => 'bulk'
  default "Auto-Submitted" => 'auto-generated'
  layout 'mailer'
end
