class Prescription < ActiveRecord::Base
  has_paper_trail
  belongs_to :prescriber, class_name: 'Staff'
  belongs_to :medication, touch: true

  before_create :set_valid_until
  before_destroy :cannot_destroy_if_signed_off
  before_save :cannot_change_medication_after_creation
  before_save :set_expiry_date

  validates_length_of :dose_and_route, minimum: 2

  after_initialize :set_defaults, if: -> { self.new_record? }

  DURATION_MULTIPLIERS = {
    'Day(s)' => 1,
    'Week(s)' => 7,
    'Mth28' => 28,
    'Mth30' => 30,
    'Mth34' => 34,
    'Year(s)' => 365
  }

  validates :duration_multiplier, inclusion: { in: DURATION_MULTIPLIERS.values }

  scope :expired, -> { where('prescriptions.expiry_date < ?', Date.today) }

  default_scope -> { order('prescriptions.created_at ASC') }

  def dose_and_route=(dr)
    write_attribute(:dose_and_route, dr.upcase)
  end

  def duration_integer=(di)
    write_attribute(:duration_integer, Integer(di.to_s, 10))
  end

  def duration_multiplier_name
    DURATION_MULTIPLIERS.select{ |k, v| v == duration_multiplier }.first.first
  end

  def duration_multiplier=(dm)
    write_attribute(:duration_multiplier, Integer(dm.to_s, 10))
  end

  def duration_in_days
    duration_integer * duration_multiplier
  end

  def pretty_start_date=(s)
    self.start_date = Date.parse(s.gsub(' ',''))
  end

  def pretty_start_date
    start_date.to_s(:long)
  end

  # You can't change the name of a prescription once it's created!
  # Prescribe using the Medication#prescribe! method.
  # TODO: For now we have this implemented so we can suggest a drug name
  # after research study randomization. Figure out a different solution.
  # def name=(n)
  #   raise NotImplementedError
  # end
  def name=(n)
    self.medication = Medication.where(name: n.upcase).first_or_initialize
  end

  def name
    medication.nil? ? '' : medication.name
  end

  class << self

    def to_pdf(ids_or_prescriptions)
      require 'prawn'
      if ids_or_prescriptions.first.is_a?(Integer)
        prescriptions = self.where(id: ids_or_prescriptions)
      else
        prescriptions = ids_or_prescriptions
      end
      patients = prescriptions.joins(:medication).map(&:medication).map(&:patient).uniq
      # TODO: Enforce only one patient printed on each PDF?
      # raise PrescriptionError, "You can only print prescriptions for one patient at a time." if patients.map(&:id).length > 1
      patient = patients.first

      info = {
        Title: "#{CLINIC_NAME} Prescription",
        Subject: "#{CLINIC_NAME} Prescription",
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

      pdf.bounding_box [pdf.bounds.left, pdf.bounds.top - 85], width: pdf.bounds.width do
        patients.each do |p|
          pdf.start_new_page unless patients.first == p
          @patient = p # For the repeater block.
          scripts = prescriptions.joins(:medication).where(medications: { patient_id: p })
          prescribers = scripts.map(&:prescriber).uniq
          prescribers.each do |prescriber|
            pdf.start_new_page unless prescribers.first == prescriber
            # Header.
            @prescriber = prescriber # For the repeater block.
            scripts.where(prescriber: prescriber).each do |script|
              # Unfortunately not implemented...
              # pdf.group do
                pdf.stroke_color "accffd"
                pdf.stroke_horizontal_rule
                pdf.move_down 4
                pdf.font "Lato"
                pdf.text script.medication.name, size: 10
                pdf.font "Lato"
                pdf.text script.dose_and_route, size: 10
                pdf.table([
                  [
                    "Duration: #{script.duration_integer} #{script.duration_multiplier_name} (#{script.duration_in_days} days)",
                    "Refills: #{script.refills}",
                    "Valid Until: #{script.valid_until.to_s(:long)}"
                  ],
                  [
                    "Start Date: #{script.start_date.to_s(:long)}",
                    '',
                    ''
                  ],
                  [
                    "Finishes: #{script.expiry_date.to_s(:long)}",
                    '',
                    ''
                  ]
                ], width: pdf.bounds.width, cell_style: { border_width: 0, size: 8, padding: 0 })
                pdf.move_down 4
                pdf.stroke_color "accffd"
                pdf.stroke_horizontal_rule
              # end
            end
          end
        end
      end

      # This block is dynamic and will pull in the instance variables on each page that is printed.
      pdf.repeat :all, dynamic: true do
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], width: pdf.bounds.width do
          pdf.font "Lato"
          pdf.text @prescriber.full_name_with_title, align: :center, size: 12
          pdf.font "Lato"
          pdf.text CLINIC_NAME, align: :center, size: 8
          pdf.text CLINIC_ADDRESS.join(', '), align: :center, size: 8
          pdf.text CLINIC_CONTACT_DETAILS.map{|k,v| "#{k[0]}: #{v}" }.join(" \u2022 "), align: :center, size: 8
          pdf.move_down 8
          pdf.line_width 2
          pdf.stroke_color "3290fe"
          pdf.transparent 0.9 do
            pdf.stroke_horizontal_rule
          end
          pdf.move_down 2
          pdf.font "Lato"
          pdf.text @patient.full_name, size: 13
          pdf.font "Lato"
          pdf.text [
            "Date of Birth: #{@patient.date_of_birth.strftime('%Y.%m.%d')} (#{@patient.short_age_in_words.gsub('m','mos').gsub('y','yrs')})",
            "Health Number: #{@patient.health_number}",
            (@patient.phone_numbers.first ? "Contact Number: #{@patient.phone_numbers.map{|k,v| k.to_s + ': ' + v }.first}" : "No contact number available")
          ].join(" \u2014 "), size: 8
          pdf.move_down 3
          pdf.transparent 0.9 do
            pdf.stroke_horizontal_rule
          end
        end
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], width: pdf.bounds.width do
          pdf.fill_color "3290fe"
          pdf.font Rails.root.join('app/assets/fonts/rx.ttf')
          pdf.text "\ue600", align: :left, size: 52
          pdf.fill_color "000000"
        end
        # Signature line.
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.bottom + 100], width: pdf.bounds.width * 0.4 do
          raise SignatureNotFoundError if @prescriber.signature_image.nil?
          pdf.image StringIO.new(@prescriber.signature_image), height: 50
          pdf.move_down 1
          pdf.line_width 1
          pdf.stroke_color "000000"
          pdf.transparent 0.7 do
            pdf.stroke_horizontal_rule
          end
          pdf.move_down 3
          pdf.font "Lato"
          pdf.text "Signature: #{@prescriber.full_name_with_title}", align: :left, size: 8
        end
      end

      # Footer.
      pdf.repeat :all do
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.bottom + 22], width: pdf.bounds.width do
          pdf.line_width 2
          pdf.stroke_color "3290fe"
          pdf.transparent 0.7 do
            pdf.stroke_horizontal_rule
          end
          pdf.move_down 2
          pdf.font "Lato"
          pdf.text "PLEASE TAKE THIS TO YOUR PHARMACIST TO BE FILLED", align: :center, size: 7
          pdf.font "Lato"
          pdf.text "#{CLINIC_NAME} \u2022 Printed #{Time.now.to_s(:friendly_long)}", align: :center, size: 7
        end
      end

      pdf.render
    end

  end

  private

  def set_defaults
    self.start_date ||= Time.now
  end

  def cannot_change_medication_after_creation
    raise "You cannot change the prescription once it has been created." unless new_record? || !self.medication_id.changed?
  end

  def cannot_destroy_if_signed_off
    raise "You cannot delete a prescription once it has been printed or faxed." if self.signed_off
  end

  def set_valid_until
    self.valid_until = (Time.now + 1.year).to_date
  end

  def set_expiry_date
    self.expiry_date = (self.start_date + (self.duration_in_days * (self.refills + 1)).days).to_date
  end

end
