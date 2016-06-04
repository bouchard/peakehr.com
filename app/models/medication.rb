class Medication < ActiveRecord::Base
  has_paper_trail
  has_many :prescriptions
  belongs_to :patient
  belongs_to :drug

  validates_presence_of :patient
  validates_presence_of :name
  validates :name, uniqueness: { case_sensitive: false, scope: :patient_id }

  before_save :associate_with_drug

  # Prescriptions touch medications so just order by our own updated_at.
  default_scope -> { order('medications.updated_at DESC') }

  scope :external, -> { where(external: true) }
  scope :prescribed, -> { joins(:prescriptions) }
  scope :current, -> { prescribed.where('prescriptions.expiry_date >= ?', Date.today) }
  scope :discontinued, -> { where.not(discontinued_at: nil) }
  scope :active, -> { where(discontinued_at: nil) }
  scope :coded, -> { where.not(drug_id: nil) }
  scope :uncoded, -> { where(drug_id: nil) }

  def name=(n)
    write_attribute(:name, n.upcase)
  end

  def latest_prescription
    prescriptions.order('prescriptions.expiry_date DESC').first
  end

  def start_date
    prescriptions.order('prescriptions.start_date ASC').first.try(:start_date)
  end

  def expiry_date
    latest_prescription.try(:expiry_date)
  end

  def current?
    expiry_date >= Date.today
  end

  def expired?
    expiry_date < Date.today
  end

  # We prescribe and discontinue as a user.
  def discontinue!(*args)
    options = args.extract_options!
    raise ArgumentError unless options[:reason] && options[:prescriber]
    self.update_attributes!(
      discontinued_at: Time.now,
      discontinued_reason: options[:reasons],
      discontinued_by: options[:prescriber]
    )
  end

  def prescribe!(*args)
    options = args.extract_options!
    self.prescriptions.create!(
      dose_and_route: options[:dose_and_route],
      duration_integer: options[:duration_integer],
      duration_multiplier: options[:duration_multiplier],
      refills: options[:refills],
      prescriber: options[:prescriber],
      start_date: options[:start_date]
    )
  end

  private

  def associate_with_drug
    d = Drug.where(name: self.name).first
    self.drug = d unless d.nil?
    true
  end

end
