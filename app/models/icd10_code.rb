class Icd10Code < ReferenceData
  has_paper_trail
  belongs_to :parent, class_name: 'Icd10Code', foreign_key: 'synonym_of_id'
  validate :set_synonym
  has_many :synonyms, class_name: 'Icd10Code', foreign_key: 'synonym_of_id'

  scope :root, -> { where(synonym_of_id: nil) }

  private

  def set_synonym
    if p = self.class.where(code: self.code).first
      self.code = nil
      self.parent = p
    end
    errors.add(:code, "Must have either a code or a parent synonym.") if self.code.nil? && self.parent.nil?
    true
  end
end