class Staff < ActiveRecord::Base
  has_paper_trail skip: [ :last_request_at ]
  has_secure_password
  has_one_time_password

  has_many :workdays
  has_many :appointments
  has_many :visits, through: :appointments
  has_many :scans, foreign_key: 'most_responsible_clinician_id'
  has_many :tasks, foreign_key: 'assigned_to_id'
  has_many :letters, foreign_key: 'creator_id'
  has_many :lab_results, foreign_key: 'most_responsible_clinician_id'

  validates_presence_of :username
  validates_uniqueness_of :username
  validates_length_of :password, minimum: 8
  validate :not_a_common_password

  serialize :roles, Array

  validate :belongs_to_at_least_one_role

  before_create :regenerate_dropbox_email_prefix, :generate_api_tokens

  attr_accessor :otp_token

  def signature_image
    require 'net/http'
    return @_sign_image if @_sign_image
    # You'll need to change this to your own domain where you'll
    # host signature files. I would suggest fetching this over HTTPS,
    # and firewalling the destination server so that only your PEAKEHR
    # production server can access it.
    u = "https://dummyserver.com/#{self.id}.jpg"
    Rails.logger.info("FETCHING Signature Image: #{u}")
    i = Net::HTTP.get_response(URI.parse(u))
    if i.kind_of? Net::HTTPSuccess
      @_sign_image = i.body
    else
      nil
    end
  end

  def full_name_with_title
    [ title, first_name, last_name, suffix ].compact.join(' ')
  end

  def self.authenticate(params = {})
    where(username: params[:username]).first.try(:authenticate, params[:password])
  end

  # Override the default role getter and setter to validate the roles.
  def roles=(r)
    r = (r.is_a?(Array) ? r.flatten.compact.map(&:to_sym) : (r || '').split(',').map(&:to_sym)) & ROLES
    write_attribute(:roles, r)
  end

  def roles
    ([ read_attribute(:roles) ].flatten & ROLES).map(&:to_sym)
  end

  def role=(r)
    self.roles = [r]
  end

  def role
    self.roles.first
  end

  def self.is?(*r)
    @_u ||= {}
    r = [r].flatten.map(&:to_sym)
    return @_u[r.join] if @_u[r.join]
    @_u[r.join] = self.select{ |u| (u.roles & r).length > 0 }
  end

  def is?(*r)
    r = [r].flatten.map(&:to_sym)
    (self.roles & r).length > 0
  end

  def dropbox_email_address
    "#{self.dropbox_email_prefix}@#{EMAIL_HOSTNAME}"
  end

  def regenerate_dropbox_email_prefix
     self.dropbox_email_prefix =  (('a'..'z').to_a - ['i', 'l']).shuffle[0,5].join
  end

  def all_tasks
    unfinished_letters + unsigned_scans + unsigned_lab_results
  end

  def unfinished_letters
    self.letters.not_signed_off
  end

  def unsigned_scans
    self.scans.not_signed_off
  end

  def unsigned_lab_results
    self.lab_results.not_signed_off
  end

  def generate_api_tokens
    self.api_key = SecureRandom.uuid
    self.api_secret = SecureRandom.hex
  end

  private

  def belongs_to_at_least_one_role
    errors.add(:roles, "Must have at least one role.") unless self.roles.count > 0
    true
  end

  def not_a_common_password
    return true unless self.password_digest_changed?
    c = COMMON_PASSWORDS.select{ |c| self.password.match(c) }
    errors.add(:password, "Cannot contain common password string '#{c[0]}'.") if c.length > 0
  end

end
