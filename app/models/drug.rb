class Drug < ReferenceData
  has_paper_trail
  has_many :medications

  validates_uniqueness_of :name

  # TODO: This model could be renamed "Monograph or DrugMonograph" to avoid confusion
  # with Medications, which may or may not be associated with a monograph (may or may
  # not be "coded"), and belong to a specific patient.
end
