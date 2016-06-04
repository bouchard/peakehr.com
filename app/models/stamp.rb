class Stamp < ActiveRecord::Base
  belongs_to :creator, class_name: 'Staff'

  scope :shared, -> { where(creator_id: nil) }
end
