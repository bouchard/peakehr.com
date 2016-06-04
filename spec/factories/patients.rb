FactoryGirl.define do
  factory :patient do
    demographics { FactoryGirl.build(:demographics) }
    sequence(:username) { |n| "#{SAMPLE_USERNAMES.sample}#{n}" }
    password { SecureRandom.urlsafe_base64(8).tr('lIO0\-_', 'sxyzab') }
    password_confirmation { password }
    chart_id { rand(1000..10000) }
    health_number { "#{rand(100..999)} #{rand(100..999)} #{rand(100..999)} SK" }
    first_name { (demographics.sex == 'm' ? COMMON_BOY_NAMES : COMMON_GIRL_NAMES).sample }
    last_name { COMMON_SURNAMES.sample }
    most_responsible_clinician { Staff.all.select { |u| u.is?(:physician) }.sample }
  end
end