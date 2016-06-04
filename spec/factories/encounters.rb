FactoryGirl.define do
  factory :encounter do
    patient
    content {
        %|S: c/o 4 days of cough with runny nose and fever.
O:
A:
P:|
    }
    created_at { rand(5.years.ago..1.day.ago) }
    updated_at { created_at }
  end
end