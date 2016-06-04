class Condition < ActiveRecord::Base
  has_paper_trail
  belongs_to :patient
end
