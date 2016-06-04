#!/usr/bin/env ruby
require 'csv'

drugs = CSV.read(File.dirname(__FILE__) + '/allfiles/drug.txt', encoding: 'ISO-8859-1')
drugs = Hash[*drugs.map do |d|
  [d[0], {
    name: d[4]
  }]
end.flatten]

forms = CSV.read(File.dirname(__FILE__) + '/allfiles/form.txt', encoding: 'ISO-8859-1')
forms.each do |f|
  drugs[f[0]] = drugs[f[0]].merge({
    form: f[2]
  })
end

routes = CSV.read(File.dirname(__FILE__) + '/allfiles/route.txt', encoding: 'ISO-8859-1')
routes.each do |f|
  drugs[f[0]] = drugs[f[0]].merge({
    route: f[2]
  })
end

schedules = CSV.read(File.dirname(__FILE__) + '/allfiles/schedule.txt', encoding: 'ISO-8859-1')
schedules.each do |f|
  drugs[f[0]] = drugs[f[0]].merge({
    schedule: f[1]
  })
end

drug_classes = CSV.read(File.dirname(__FILE__) + '/allfiles/ther.txt', encoding: 'ISO-8859-1')
drug_classes.each do |f|
  drugs[f[0]] = drugs[f[0]].merge({
    class: f[4]
  })
end

vet_drugs = CSV.read(File.dirname(__FILE__) + '/allfiles/vet.txt', encoding: 'ISO-8859-1')
vet_drugs.each do |f|
  drugs.delete(f[0])
end

# TODO: Find a database for this. For now we just have a few suggested initial
# dose ranges for the statins.
suggested_initial_dose_ranges = {
  'ATORVASTATIN' => '10MG PO DAILY',
  'FLUVASTATIN' => '20MG PO DAILY',
  'LOVASTATIN' => '20-40MG PO DAILY',
  'PRAVASTATIN' => '20MG PO DAILY',
  'ROSUVASTATIN' => '20MG PO DAILY',
  'SIMVASTATIN' => '20-40MG PO DAILY'
}

drugs.each_pair do |id,d|
  puts d[:name]
  # Remove manufacturer prefix:
  m = [
    'APO', 'TEVA', 'MYLAN', 'AURO', 'JAMP', 'MINT',
    'RAN', 'SEPTA', 'DOM', 'RIVA', 'MAR', 'AVA', 'PMS',
    'PHL', 'ACCEL', 'SANDOZ', 'GD', 'CO'
  ].map{ |a| [ "#{a}-", "#{a}\s" ] }.flatten
  drug = Drug.where(identifier: id).first_or_initialize(
    name: d[:name].gsub(/^(#{m.join('|')})/,''),
    form: d[:form],
    route: d[:route],
    schedule: d[:schedule],
    drug_class: d[:class],
    suggested_dose_range: suggested_initial_dose_ranges[d[:name].gsub(/^(#{m.join('|')})/,'')]
  )
  # We don't care if this fails, drug names shouldn't be duplicated.
  drug.save
end