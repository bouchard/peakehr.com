require 'factory_girl_rails'
# require Rails.root.join('data', 'snomed_ct', 'update_snomed_ct')
# require Rails.root.join('data', 'icd10', 'update_icd10')
require Rails.root.join('data', 'health_canada_drug_database', 'update_drugs')

physicians = (1..5).map { FactoryGirl.create(:physician) }
master_staff = FactoryGirl.create(:master_staff)
study = FactoryGirl.create(:study) # Our sham statin trial.

STAMPS = Dir[Rails.root.join('data', 'stamps', '*.txt')].inject({}) do |h, f|
  h[File.basename(f, '.txt')] = File.read(f)
  h
end
STAMPS.each { |k,v| Stamp.create(title: k, body: v) }