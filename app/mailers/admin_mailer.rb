class AdminMailer < ActionMailer::Base
  layout 'mailer'
  default from: "PeakEHR Bot <support@peakehr.com>"
  default to: "Brady Bouchard <brady@thewellinspired.com>"
  before_filter :add_header_inline

  def new_support_request(params)
    @params = params
    mail(
      subject: "New Support Request"
    )
  end

  private

  def add_header_inline
    attachments.inline['mail-logo.png'] = File.read(Rails.root.join('app', 'assets', 'images', 'mail-logo.png'))
  end
end
