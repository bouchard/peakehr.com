class Encounter < ActiveRecord::Base
  has_paper_trail
  belongs_to :patient
  belongs_to :signer, class_name: 'Staff', foreign_key: 'signed_off_by_id'
  belongs_to :responsible_clinician, class_name: 'Staff'
  belongs_to :icd10_code
  has_one    :dropbox
  has_many   :attachments, as: :attachable

  before_save :raise_if_signed_off
  before_save :ensure_valid_before_sign_off
  around_create :dont_version_if_recent_change

  default_scope -> { order('encounters.created_at ASC') }

  scope :signed_off, -> { where(state: 'signed_off') }
  scope :not_signed_off, -> { where('state != ?', 'signed_off') }
  scope :today, -> { where('encounters.created_at > ?', Time.now.midnight).where('encounters.created_at < ?', Time.now.midnight + 1.day) }
  scope :old, -> { where('encounters.created_at < ?', Time.now.midnight) }

  state_machine initial: :created do
    before_transition any => :signed_off, do: :do_sign_off
    event :sign_off do
      transition created: :signed_off
    end
  end

  validates_presence_of :responsible_clinician

  def title
    if persisted?
      "Encounter with #{self.responsible_clinician.full_name_with_title}"
    else
      "New Encounter"
    end
  end

  # Override event sign_off so we can pass arguments. Apparently there's no better way to do that.
  def sign_off(user)
    @_sign_off_user = user
    super
    @_sign_off_user = nil
  end

  def do_sign_off
    raise ArgumentError unless @_sign_off_user && @_sign_off_user.is_a?(Staff)
    self.signed_off_by_id = @_sign_off_user.id
    self.signed_off_at = Time.now
    self.save!
  end

  private

  # TODO: Don't save a new encounter version if changed very recently and by the same whodunnit.
  def dont_version_if_recent_change
    yield
  end

  def raise_if_signed_off
    errors.add(:signed_off, 'Cannot save if encounter signed off.') if self.signer
  end

  def ensure_valid_before_sign_off
    errors.add(:icd10_code, 'Needs to be coded before signing off.') if self.signer && self.icd10_code.nil?
  end
end