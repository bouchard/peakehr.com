class Reminder < ActiveRecord::Base
  has_paper_trail
  belongs_to :patient
  belongs_to :creator, class_name: 'Staff'

  validates_presence_of :actionable_after

  scope :actioned, -> { where('actioned_at IS NOT NULL') }
  scope :actionable, -> { where('actionable_after >= ?', Time.now) }
  scope :active, -> { where(actioned_at: nil) }
end
