# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'CodeHarbor <openhpi-support@hpi.uni-potsdam.de>'
  default 'Precedence' => 'bulk'
  default 'Auto-Submitted' => 'auto-generated'
  layout 'mailer'
end
