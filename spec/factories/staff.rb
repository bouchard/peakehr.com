FactoryGirl.define do
  factory :staff do
    username { SAMPLE_USERNAMES.sample }
    password { SecureRandom.urlsafe_base64(8).tr('lIO0\-_', 'sxyzab') }
    password_confirmation { password }
    first_name { (COMMON_BOY_NAMES + COMMON_GIRL_NAMES).sample }
    last_name { COMMON_SURNAMES.sample }
    factory :physician do
      username { SAMPLE_USERNAMES.sample }
      password { SecureRandom.urlsafe_base64(8).tr('lIO0\-_', 'sxyzab') }
      password_confirmation { password }
      first_name { (COMMON_BOY_NAMES + COMMON_GIRL_NAMES).sample }
      last_name { COMMON_SURNAMES.sample }
      title 'Dr.'
      role :physician
    end
    factory :master_staff do
      username 'brady'
      password 'bradybrady'
      password_confirmation 'bradybrady'
      first_name 'Brady'
      last_name 'Bouchard'
      title 'Dr.'
      role :physician
    end
  end
end