class ApplicationMailer < ActionMailer::Base
  default :from => "openhpi-support@hpi.uni-potsdam.de"
  default "Precedence" => 'bulk'
  default "Auto-Submitted" => 'auto-generated'
  layout 'mailer'
end
