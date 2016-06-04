class Study < ActiveRecord::Base
  has_paper_trail
  has_many :study_enrollments
  has_many :patients, through: :study_enrollments

  serialize :triggers, JSON
  serialize :randomize_from, JSON
  serialize :eligibility_requirements, JSON

  validate :validate_end_dates, on: :create
  validate :validate_eligibility_requirements

  def self.match_study_type_and_drug(s, d)
    # TODO: Should be implemented in database with LIKE search.
    # For now we want to match on every substring (broken on word boundaries),
    # so we do it in Rails.
    # where(study_type: s).where('"triggers" LIKE ?', "%#{d.downcase}%").first
    search_term_regex = d
      .split(/\b/).reject{ |term| term.length <= 4 }
      .map{ |term| term.upcase.gsub(/[^0-9A-Z]/i, '') }
      .join('|')
    search_term_regex = /#{search_term_regex}/i

    where(study_type: s).select do |study|
      !study.triggers.select { |t| t.match(search_term_regex) }.empty?
    end.flatten.first
  end

  private

  def validate_eligibility_requirements
    errors.add(:eligibility_requirements, 'eligibility_requirements must be an array') unless self.eligibility_requirements.is_a?(Array)
  end

  def validate_end_dates
    errors.add(:end_date, 'Study end date must be in the future.') if self.end_date < Time.now
  end

end
