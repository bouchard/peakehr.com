class LabResult < ActiveRecord::Base
  has_paper_trail
  belongs_to :signer, class_name: 'Staff', foreign_key: 'signed_off_by_id'
  belongs_to :most_responsible_clinician, class_name: 'Staff'

  serialize  :serialized_results, JSON

  scope :signed_off, -> { where(state: 'signed_off') }
  scope :not_signed_off, -> { where('state != ?', 'signed_off') }

  state_machine initial: :created do
    before_transition any => :signed_off, do: :do_sign_off
    event :sign_off do
      transition created: :signed_off
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

end
