class Letter < ActiveRecord::Base
  has_paper_trail
  belongs_to :patient
  belongs_to :creator, class_name: 'Staff'
  belongs_to :sender, class_name: 'Staff', foreign_key: 'sent_by_id'

  after_initialize :set_default_content

  scope :signed_off, -> { where(state: 'signed_off') }
  scope :not_signed_off, -> { where('state != ?', 'signed_off') }

  state_machine initial: :created do
    before_transition any => :signed_off, do: :do_sign_off
    event :sign_off do
      transition created: :signed_off
    end
    before_transition any => :sent, do: :do_send
    event :send_letter do
      transition signed_off: :sent
    end
  end

  def set_default_content
    return true if self.creator.nil?
    self.content ||= %|#{self.creator.default_letter_greeting} <addressee>,

#{self.creator.default_letter_closing.gsub(/\,$/,'')},
<signature>
#{self.creator.full_name_with_title}|
  end

  def title
    "Letter to #{(self.to_address || '').strip.split("\n")[0]}"
  end

  def do_sign_off
    self.signed_off_at = Time.now
    self.save!
  end

  # Override event sign_off so we can pass arguments. Apparently there's no better way to do that.
  def send_letter(user)
    @_user_who_sent = user
    super
    @_user_who_sent = nil
  end

  def do_print
    raise ArgumentError unless @_user_who_sent && @_user_who_sent.is_a?(Staff)
    self.sent_by_id = @_user_who_sent.id
    self.sent_at = Time.now
    self.save!
  end

  def to_pdf
    require 'prawn'
    info = {
      Title: self.title,
      Author: self.creator.full_name_with_title,
      Subject: self.title,
      CreationDate: Time.now,
      Creator: "Inspired EHR - Version #{CURRENT_VERSION}"
    }
    pdf = Prawn::Document.new(info: info)

    # Fonts for this document.
    pdf.font_families.update(
      "Lato" => {
        normal: Rails.root.join('app/assets/fonts/Lato-Regular.ttf'),
        bold: Rails.root.join('app/assets/fonts/Lato-Bold.ttf')
      },
      "Peak EHR Logo" => {
        normal: Rails.root.join('app/assets/fonts/peak-health.ttf')
      }
    )

    #### Header. ####
    pdf.font "Lato"
    pdf.text CLINIC_NAME.upcase, align: :center, size: 14, style: :bold
    pdf.font "Lato"
    pdf.text CLINIC_ADDRESS.join(', '), align: :center, size: 8
    pdf.text CLINIC_CONTACT_DETAILS.map{|k,v| "#{k[0]}: #{v}" }.join(" \u2022 "), align: :center, size: 8

    pdf.line_width 2
    pdf.move_down 12
    pdf.stroke_color "3A4858"
    # pdf.line_width 2
    # pdf.transparent 0.7 do
    #   pdf.stroke_horizontal_rule
    # end
    # pdf.move_down 2
    pdf.line_width 3
    pdf.transparent 0.8 do
      pdf.stroke_horizontal_rule
    end
    pdf.move_down 3
    pdf.line_width 4
    pdf.transparent 0.6 do
      pdf.stroke_horizontal_rule
    end

    pdf.move_down 16
    pdf.font_size 10
    pdf.text self.to_address
    pdf.move_down 16
    pdf.text self.created_at.to_date.to_s(:long)
    pdf.move_down 16
    pdf.font "Lato"
    pdf.text [
      "RE: #{self.patient.full_name}",
      "DOB: #{self.patient.date_of_birth.strftime('%Y.%m.%d')} (#{self.patient.short_age_in_words.gsub('m','mos').gsub('y','yrs')})",
      "Health Number: #{self.patient.health_number}",
      "Chart \#: #{self.patient.chart_id}"
    ].join(" \u2014 "), style: :bold

    pdf.font_size 10
    pdf.font "Lato"
    pdf.move_down 16
    contents = self.content.split('<signature>')
    if contents.length > 1
      contents[0..-2].each do |c|
        pdf.text c
        raise SignatureNotFoundError if self.creator.signature_image.nil?
        pdf.move_down 6
        pdf.image StringIO.new(self.creator.signature_image), height: 50
      end
      pdf.text contents[-1]
    else
      pdf.text self.content
      raise SignatureNotFoundError if self.creator.signature_image.nil?
      pdf.move_down 6
      pdf.image StringIO.new(self.creator.signature_image), height: 50
    end

    pdf.font_size 7
    string = "#{CLINIC_NAME} \u2022 Page <page> of <total> \u2022 #{self.created_at.to_date.to_s(:long)}"

    # Page numbers.
    options = { at: [0, 0],
      width: pdf.bounds.width,
      align: :center,
      color: "333333" }
    pdf.number_pages string, options

    # Footer stroke and PEAK logo.
    pdf.repeat :all do

      right_offset = 84
      pdf.bounding_box [pdf.bounds.left, pdf.bounds.bottom + 11], width: pdf.bounds.width - right_offset do
        pdf.fill_color "5B7496"
        pdf.font "Peak EHR Logo"
        pdf.text "\ue600", align: :center, size: 8
      end

      left_offset = 29
      pdf.bounding_box [pdf.bounds.left + left_offset, pdf.bounds.bottom + 10], width: pdf.bounds.width - left_offset do
        pdf.fill_color "5B7496"
        pdf.font "Lato"
        pdf.text "Electronic Health Record", align: :center, size: 7.5
      end

      pdf.bounding_box [pdf.bounds.left, pdf.bounds.bottom + 17], width: pdf.bounds.width do
        pdf.fill_color "000000"
        pdf.line_width 2
        pdf.transparent 0.1 do
          pdf.stroke_horizontal_rule
        end
        pdf.move_down 2
        pdf.line_width 2
        pdf.transparent 0.4 do
          pdf.stroke_horizontal_rule
        end
      end

    end
    pdf.render
  end

  def to_png(page = 1)
    pdf = Tempfile.new(['letter', '.pdf'], encoding: 'ASCII-8BIT')
    pdf.write self.to_pdf
    png = Tempfile.new(['letter', '.png'])
    executable = Rails.env.development? ? 'mudraw' : 'pdfdraw'
    output = `#{executable} -o #{png.path} -r 150 #{pdf.path} #{page}`
    raise MuDrawError, output unless $?.success?
    image = png.read
    png.close! and pdf.close!
    image
  end
end
