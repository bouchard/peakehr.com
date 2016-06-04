# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :study do
    name 'Comparative Effectiveness of Current On-the-market Statins'
    description %|This research study is a sham, intention to treat
    comparative effectiveness study aiming to compare the six (6) drugs in the
    statin class currently available in Canada. Outcome measures include 5 year
    mortality data (to be gathered from provincial registries). Pre-specified
    subgroups for analysis include sex (male, female).|
    triggers [
      'atorvastatin', 'lipitor',
      'fluvastatin', 'lescol',
      'lovastatin', 'mevacor',
      'pravastatin', 'pravachol',
      'rosuvastatin', 'crestor',
      'simvastatin', 'zocor'
    ]
    randomize_from [
      'atorvastatin',
      'fluvastatin',
      'lovastatin',
      'pravastatin',
      'rosuvastatin',
      'simvastatin'
    ]
    eligibility_requirements [
      'Has never previously been on a statin',
      'Has no history of cardiovascular disease (no previous MI or stroke)'
    ]
    study_type 'intention_to_treat'
    start_date Time.now
    end_date 1.year.from_now
  end
end