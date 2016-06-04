IMAGES = Dir.glob(Rails.root.join('working', 'test_attachments','*.jpg'))

FactoryGirl.define do
  factory :email, class: OpenStruct do
    # Assumes Griddler.configure.to is :hash (default)
    to {[{
      full: encounter.responsible_clinician.dropbox_email_address,
      email: encounter.responsible_clinician.dropbox_email_address,
      token: encounter.responsible_clinician.dropbox_email_address.split('@')[0],
      host: encounter.responsible_clinician.dropbox_email_address.split('@')[1],
      name: nil
    }]}
    from 'brady@bradybouchard.ca'
    subject { "#{encounter.dropbox.code} Left shoulder rash @ 1 week of treatment, < 24 hrs since onset of rash." }
    body 'Blah blah blah.'
    attachments {[]}
    trait :with_attachment do
      attachments {[
        ActionDispatch::Http::UploadedFile.new({
          filename: File.basename(image),
          type: 'image/jpg',
          tempfile: File.new(image)
        })
      ]}
    end

    image { IMAGES.sample }
    encounter { false }
  end
end