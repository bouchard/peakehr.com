class Time
  # Time#round already exists with different meaning in Ruby 1.9
  def round_off(sec = 60, floor = false)
    down = self - (self.to_i % sec)
    up = down + sec

    difference_down = self - down
    difference_up = up - self

    if difference_down < difference_up || floor
      return down
    else
      return up
    end
  end
  def floor(sec = 60)
    round_off(sec, true)
  end
end

FactoryGirl.define do
  factory :appointment do
    booked_at {
      Time.zone = staff.time_zone
      d = rand(1.day.from_now..3.months.from_now).to_date
      # Generated within default office hours.
      staff.workdays.new(date: d).office_hours.map{ |o| rand(o[0]..o[1]) }.sample.floor(APPOINTMENT_INTERVAL)
    }
    length_in_seconds { [15, 30, 45, 60].map(&:minutes).sample }
    one_liner {
      ['Complete, no pap.',
        'Back pain',
        '4 week old check',
        '? Shingles',
        'Histofreeze',
        'Stitches out today',
        'Cough x 4 weeks',
        'Prenatal - 20 weeks',
        '? Bit by bee'].sample
    }
    factory :past_appointment do
      booked_at {
        Time.zone = staff.time_zone
        d = rand(4.months.ago..1.day.ago).to_date
        # Generated within default office hours.
        staff.workdays.new(date: d).office_hours.map{ |o| rand(o[0]..o[1]) }.sample.floor(APPOINTMENT_INTERVAL)
      }
    end
  end
end
