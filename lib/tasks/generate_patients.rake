namespace :db do
  "Seed NUMBER || 200 new patients into the database."
  task :seed_patients => :environment do
    raise StandardError, "Cannot seed into the production database!" if Rails.env.production?
    physicians = Staff.is?(:physician)
    icd10codes = Icd10Code.all.map(&:id)
    (ENV['NUMBER'] || 200).to_i.times do
      p = FactoryGirl.build(:patient, :most_responsible_clinician => physicians.sample)
      p.save!
      puts p.inspect

      rand(1..40).times do
        v = nil
        a = FactoryGirl.build(:past_appointment, :patient => p, :staff => physicians.sample) do |appointment|
          v = FactoryGirl.build(:visit, :appointment => appointment, :completed => true)
        end
        a.save(:validate => false)
        v.save(:validate => false)
      end

      rand(0..6).times do
        FactoryGirl.create(:appointment, :patient => p, :staff => physicians.sample)
      end

      encounters = rand(1..20).times.map do |n|
        e = FactoryGirl.create(:encounter, :patient => p, :responsible_clinician => physicians.sample)
        e.update_column(:icd10_code_id, icd10codes.sample)
        if rand(1..10) > 9 # 1/10th the time.
          d = e.create_dropbox
          email = FactoryGirl.create(:email, :with_attachment, :encounter => e)
          EmailProcessor.process(email)
        end
      end

      rand(1..10).times do
        n = FactoryGirl.build(:letter, :patient => p, :creator => physicians.sample)
        n.save!
      end

      rand(1..2).times do
        n = FactoryGirl.build(
          :letter,
          :patient => p,
          :creator => physicians.sample,
          :created_at => rand(1.day.ago..5.minutes.ago)
        )
        n.save(:validate => false)
      end

      rand(0..5).times do
        FactoryGirl.create(:condition, :patient => p)
      end

      medications = [
        [ 'SYNTHROID - TAB 125MCG', '1 tab PO OD' ],
        [ 'CITALOPRAM', '20mg PO OD' ],
        [ 'NITRO SUBLINGUAL SPRAY', 'SL PRN' ],
        [ 'VENTOLIN HFA', '100mcg PRN' ],
        [ 'SEREVENT DISKUS (50MCG/DOSE)', '1 puff BD' ],
        [ 'AMITRIPTYLINE', '10mg PO OD' ],
        [ 'ATENOLOL', '50mg PO OD' ],
        [ 'SOTALOL', '240mg PO OD' ],
        [ 'NAPROXEN EC', '500mg PO QID PRN' ],
        [ 'BACLOFEN', '10mg PO BD' ],
        [ 'ATIVAN', '1mg PO HS' ],
        [ 'ALESSE 21', '1 tab PO OD' ],
        [ 'HYDROMORPHONE CORTIN', '2mg PO BD' ],
        [ 'LIPITOR', '10mg PO OD' ],
        [ 'CRESTOR', '10mg PO OD' ],
        [ 'EZETROL', '10mg PO OD' ],
        [ 'ESCITALOPRAM', '10mg PO OD' ],
        [ 'PREDNISONE', '5mg PO mane' ],
        [ 'TYLENOL', '500mg Q4H PRN' ],
        [ 'MIRENA', 'IUD' ],
        [ 'CAPTOPRIL', '12.5mg PO OD' ],
        [ 'RAMIPRIL', '5mg PO OD' ],
        [ 'SUMATRIPTAN', '10mg SL PRN' ],
        [ 'PAROXETINE', '40mg PO OD' ]
      ]
      rand(1..10).times do
        s = medications.sample
        phys = physicians.sample
        m = p.medications.where(:name => s[0].upcase).first_or_create!
        m.prescribe!(
          :dose_and_route => s[1],
          :prescriber => phys,
          :duration_integer => rand(1..20),
          :duration_multiplier => Prescription::DURATION_MULTIPLIERS.values.sample,
          :refills => rand(0..5),
          :start_date => Time.now
        )
      end
    end
    patients = Patient.all
    patients.each do |p|
      p.encounters[0..-rand(2..3)].map{ |e| e.sign_off(e.responsible_clinician) }
    end
  end
end