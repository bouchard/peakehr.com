class Appointment < ActiveRecord::Base
  has_paper_trail
  has_one :visit
  belongs_to :patient
  belongs_to :staff
  belongs_to :workday, touch: true

  default_scope -> { order('booked_at ASC') }
  scope :by_date, -> (d) { where('booked_at > ? AND booked_at < ?', d.midnight, (d + 1.day).midnight) }

  before_save :ensure_workday_exists
  validate :booked_at_in_the_future
  validates :length_in_seconds, inclusion: { in: 300..7200 }

  def patient_arrived!
    self.visit.first_or_create
  end

  def booked_at_in_the_future
    errors.add(:booked_at, "must be in the future.") unless booked_at && booked_at > Time.now
  end

  def ensure_workday_exists
    self.workday = self.staff.workdays.where(date: self.booked_at.to_date).first_or_create
  end

  def ensure_booked_at_on_appointment_interval_boundary
    errors.add(:booked_at, "must be in #{APPOINTMENT_INTERVAL} second intervals.") unless self.booked_at.to_i % 5.minutes == 0
  end
end
