# Add reminders based on evidence-based guidelines for patient screening.

# Alcoholic abuse
# Screening frequency: Opportunistic

# AAA
# Start: Men aged 65 who have ever smoked
# Stop: Age 75
# Frequency: once
# Options: Ultrasound
# References: USPSTF (2005), Journal of Vascular Surgery, Vol 55, No 5 (2012)
Patient.male.where('demographics.date_of_birth <= ?', 65.years.ago).where('demographics.date_of_birth >= ?', 75.years.ago).each do |p|
  r = p.reminders.where(based_on_screening_recommendation: 'AAA').first_or_initialize
  unless r.persisted?
    r.actionable_after = Time.now
    r.title = "AAA Screening"
    r.comment = %|Once-off screening for abdominal aortic aneurysm is recommended for men who have previously smoked and are between the ages of 65 and 75.
References: Journal of Vascular Surgery, Vol 55, No 5 (2012), USPSTF (2005)|
    r.save
    puts "Created #{r.inspect}"
  end
end

# Breast Cancer
# Start: Women at average risk > age 50
# Stop: ?75
Patient.female.where('demographics.date_of_birth <= ?', 50.years.ago).where('demographics.date_of_birth >= ?', 75.years.ago).each do |p|
  r = p.reminders.actioned.where('actioned_at <= ?', 23.months.ago).where(based_on_screening_recommendation: 'Breast Cancer').first ||
    p.reminders.active.where(based_on_screening_recommendation: 'Breast Cancer').first_or_initialize
  unless r.persisted?
    r.actionable_after = Time.now
    r.title = "Breast Cancer Screening"
    r.comment = %|Biennial screening (with mammography and/or clinical breast exam) is weakly recommended for women who are between the ages of 50 and 75.
Decision Aid: http://www.phac-aspc.gc.ca/cd-mc/mammography-mammographie-eng.php
References: Journal of Vascular Surgery, Vol 55, No 5 (2012), USPSTF (2005)|
    r.save
    puts "Created #{r.inspect}"
  end
end