FactoryGirl.define do
  factory :visit do
    appointment
    start_time { appointment.booked_at + rand(30.minutes) }
    end_time { start_time + rand(5.minutes..45.minutes) }
  end
end