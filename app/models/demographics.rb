class Demographics < ActiveRecord::Base
  has_paper_trail
  belongs_to :patient

  validates_inclusion_of :sex, in: %w( m f )
  validate :date_of_birth_in_range

  serialize :addresses, Hash
  serialize :phone_numbers, Hash

  # Format Phone Numbers for display.
  def phone_numbers
    delimiter = '.'
    super.each_with_object({}){ |(k,v), h| h[k] = v.gsub(/(\d{0,3})(\d{3})(\d{4})$/,"\\1#{delimiter}\\2#{delimiter}\\3") }
  end

  def age
    now = Time.now.utc.to_date
    now.year - date_of_birth.year - ((now.month > date_of_birth.month || (now.month == date_of_birth.month && now.day >= date_of_birth.day)) ? 0 : 1)
  end

  def short_age_in_words
    now = Time.now.utc
    if now - date_of_birth.to_time < 1.year
      "#{((now - date_of_birth.to_time) / 1.month).floor}m"
    else
      "#{((now - date_of_birth.to_time) / 1.year).floor}y"
    end
  end

  private

  def date_of_birth_in_range
    errors.add(:date_of_birth, "must be between now and 130 years ago.") unless date_of_birth && date_of_birth > 130.years.ago && date_of_birth <= Time.now
  end

end
