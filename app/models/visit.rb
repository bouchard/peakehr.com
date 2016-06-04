class Visit < ActiveRecord::Base
  has_paper_trail
  belongs_to :appointment, touch: true

  before_save :calculate_duration
  validates_presence_of :start_time
  validates_presence_of :end_time
  validate :cant_create_visit_in_the_future

  scope :completed, -> { where(completed: true) }
  scope :active, -> { where(completed: false) }

  private

  def cant_create_visit_in_the_future
    errors.add(:start_time) if self.start_time > Time.now
    errors.add(:end_time) if self.end_time > Time.now
    true
  end

  def calculate_duration
    self.duration_in_seconds = ((end_time - start_time) / 1.day).round
    true
  end
end
