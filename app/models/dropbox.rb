class Dropbox < ActiveRecord::Base
  has_paper_trail
  belongs_to :encounter
  before_create :generate_code

  scope :active, -> { where('updated_at > ?', 60.minutes.ago) }

  def active?
    self.updated_at > 60.minutes.ago
  end

  def inactive?
    !active?
  end

  private

  # Ensure code has at least one digit in it to greatly decrease our chances of matching a word in an email that isn't the code.
  # 1.6 million possible codes hopefully strikes the right balance between convenience and security.
  def generate_code
    chars = ('a'..'z').to_a + (0..9).map{|i| i.to_s } - %w|1 i l o 0|
    begin
      self.code = chars.shuffle[0,4].join
    end while !self.code.match(/\d/)
  end
end
