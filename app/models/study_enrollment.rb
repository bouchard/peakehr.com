class StudyEnrollment < ActiveRecord::Base
  has_paper_trail
  belongs_to :patient
  belongs_to :study
  belongs_to :enrolling_staff, class_name: 'Staff'

  before_create :set_consent_obtained_at
  before_create :perform_randomization
  validate :ensure_consent_obtained

  attr_writer :consent_obtained

  # TODO: Figure out how to get Rails to do boolean conversions on virtual attributes, as below.
  def consent_obtained
    @consent_obtained == '1'
  end

  def perform_randomization
    self.randomized_to = self.study.randomize_from.sample
  end

  def randomized_to=(r)
    if self.persisted?
      errors.add(:randomized_to, "Cannot re-randomize after enrollment has been created!")
    else
      write_attribute(:randomized_to, r)
    end
  end

  private

  def set_consent_obtained_at
    self.consent_obtained_at = Time.now if self.consent_obtained
    logger.info('*' * 40)
    logger.info(self.consent_obtained.inspect)
    true
  end

  def ensure_consent_obtained
    errors.add(:consent_obtained, 'Please make sure consent has been obtained from your patient.') unless self.consent_obtained
  end

end
