class Workday < ActiveRecord::Base
  has_paper_trail
  belongs_to :staff
  has_many   :appointments
  serialize  :office_hour_intervals_in_seconds, JSON
  before_save :office_hours
  after_initialize :must_have_valid_date

  def office_hours
    Time.zone = self.staff.time_zone
    if self.office_hour_intervals_in_seconds.nil? || self.office_hour_intervals_in_seconds.length == 0
      self.office_hours = DEFAULT_OFFICE_HOURS
    end
    @_oh ||= self.office_hour_intervals_in_seconds.map{ |i| i.map{ |o| self.date.midnight + o } }
  end

  def office_hours=(o)
    raise "office_hours must be assigned as an nested array of time intervals." unless o.is_a?(Array) && o.first.is_a?(Array)
    @_oh = nil
    self.office_hour_intervals_in_seconds = o.map{ |a| a.map{ |t| (Time.parse(t) - Time.parse(t).midnight).to_i } }
  end

  def availability_percentage
    not_available = self.appointments.where('booked_at > ? AND booked_at < ?', date.midnight, date.midnight + 24.hours).map do |a|
      ((a.booked_at.to_i - date.midnight.to_i)..(a.booked_at.to_i - date.midnight.to_i + a.length_in_seconds)).step(APPOINTMENT_INTERVAL)
    end.flatten.sort.uniq
    (100 * (self.office_hours_availability - not_available) / self.office_hours_availability).round
  end

  def office_hours_availability
    @_office_hours_availability ||= self.office_hour_intervals_in_seconds.map do |i|
      (i[0]..(i[1] - 1)).step(APPOINTMENT_INTERVAL)
    end.flatten.sort.uniq
  end

  class << self

    def all_day_availability
      @@_all_day_availability ||= (0..(24.hours - 1)).step(APPOINTMENT_INTERVAL) # 288 discrete appointment blocks possible.
    end

  end

  private

  def must_have_valid_date
    self.date ||= Date.today
  end

end
