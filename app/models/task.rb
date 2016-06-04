class Task < ActiveRecord::Base
  has_paper_trail
  belongs_to :patient
  belongs_to :creator, class_name: 'Staff'
  belongs_to :actioner, class_name: 'Staff', foreign_key: 'assigned_to_id'

  scope :actioned, -> { where('actioned_at IS NOT NULL') }
  scope :active, -> { where(actioned_at: nil) }
end
