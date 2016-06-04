conditions = {
  'Hypertension' => 'Initial BP 158/80, target is 130/80.',
  'Dyslipidemia' => 'Initial LDL was 5.8, target is 2.0-2.9.',
  'Hypothyroidism' => 'Treated with Thyroxine',
  'L TKR' => 'Done by Dr. Smith in 2008.',
  'R hip # and replacement' => 'Done by Dr. Smith in 2008.',
  'IHD' => 'Stress test positive 1998.',
  'CABG (1998)' => 'Three vessel disease, followed by Dr. Cardio.'
}

FactoryGirl.define do
  factory :condition do
    name { conditions.keys.sample }
    details { conditions[name] }
    diagnosed_at { [ rand(30.years.ago..Time.now).to_date, nil ].sample }
  end
end
