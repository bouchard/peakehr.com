class Patient < ActiveRecord::Base
  has_paper_trail
  has_many :appointments
  has_many :visits, through: :appointments
  has_many :conditions
  has_many :prescriptions, through: :medications
  has_many :medications
  has_many :encounters
  has_many :letters
  has_many :reminders
  has_many :tasks
  has_many :study_enrollments
  has_one  :demographics, autosave: true
  belongs_to :most_responsible_clinician, class_name: 'Staff'

  has_secure_password

  after_create :create_default_demographics

  validates_presence_of :chart_id
  validates_presence_of :most_responsible_clinician
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_length_of :password, minimum: 8
  validate :not_a_common_password

  delegate :date_of_birth, :sex, :occupation, :age, :short_age_in_words,
    :phone_numbers, :addresses, to: :demographics

  scope :isearch, -> (h) { where([ h.map{ |k,v| "#{k} ILIKE ?" }.join(" OR "), h.values.map{ |v| "%#{v}%" } ].flatten) }
  scope :male, -> { joins(:demographics).where('demographics.sex = ?', 'm') }
  scope :female, -> { joins(:demographics).where('demographics.sex = ?', 'f') }

  def self.authenticate(params = {})
    where(username: params[:username]).first.try(:authenticate, params[:password])
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  # Shim so we can do patient.is?(:patient) rather than patient.class == 'Patient'
  def is?(*r)
    r = [r].flatten.map(&:to_sym)[0]
    r == :patient
  end

  private

  def create_default_demographics
    create_demographics unless demographics
  end

  def not_a_common_password
    return true unless self.password_digest_changed?
    c = COMMON_PASSWORDS.select{ |c| self.password.match(c) }
    errors.add(:password, "Cannot contain common password string '#{c[0]}'.") if c.length > 0
  end

end
