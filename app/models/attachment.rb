class Attachment < ActiveRecord::Base
  has_paper_trail
  belongs_to :attachable, polymorphic: true, touch: true
  has_attached_file :file,
    styles: { thumb: [ '25x25#', :jpg ], large: [ '2580x2048>', :jpg ] },
    default_style: :large,
    default_url: '/images/attachment/:style_missing.jpg'

  validates_attachment :file, presence: true,
    content_type: { content_type: 'image/jpg' },
    size: { in: 0..10.megabytes }
end
