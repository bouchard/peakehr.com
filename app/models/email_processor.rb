class EmailProcessor
  class << self
    def process(email)
      physician = grab_clinician(email.to.map{ |t| t[:email] })
      d = Dropbox.active.where(code: possible_codes(email.subject + ' ' + email.body)).first
      raise DropboxError, "A Dropbox with code #{to} wasn't found." unless d
      raise DropboxError, "Can't attach picture as this encounter \##{d.encounter.id} is already signed off." if d.encounter.signed_off?
      # Assume the biggest attachment is the one we want, in case email image footers are included.
      file = email.attachments.sort_by(&:size).last
      a = d.encounter.attachments.create!(file: file, comment: comment_text(email, d.code))
      Rails.logger.info('*' * 40)
      Rails.logger.info('RECEIVED EMAIL')
      Rails.logger.info(email.inspect)
    end

    private

    def grab_clinician(recipients)
      r = recipients.select{ |a| a =~ /@#{EMAIL_HOSTNAME}$/ }.map{ |a| a.gsub(/@#{EMAIL_HOSTNAME}$/,'') }
      u = Staff.where(dropbox_email_prefix: r).first!
      a = Ability.new(u)
      a.authorize! :update, Encounter
    end

    # Dropbox generated codes are 4 characters in length, with at least one digit.
    # Because I'm not clever enough to combine into one regex, two instead!
    def possible_codes(text)
      text.scan(/\b[a-z0-9]{4}\b/i).select{ |c| c.match(/\d/) }
    end

    def comment_text(email, code)
      # Remove the code from the email subject if it's in there.
      subject = email.subject.gsub(/\s*(code)?[^a-z0-9]*#{code}/i, '').strip
      # If subject is insubstantial when code removed, then use the first line of the
      # body as the comment instead.
      subject.gsub(/[^a-z0-9]/i, '').length < 2 ? email.body.split("\n")[0] : subject
    end
  end
end