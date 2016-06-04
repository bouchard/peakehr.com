class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :initialize_client_side_state, :set_last_request_at, :set_timezone
  helper_method :signed_in?, :current_user, :patient_signed_in?, :staff_signed_in?

  def trusted_computer?
    begin
      Time.parse(cookies.signed[:trusted_until].to_s) > Time.now
    rescue ArgumentError
      false
    end
  end

  def patient_signed_in?
    signed_in? && current_user.is?(:patient)
  end

  def staff_signed_in?
    signed_in? && current_user.is_a?(Staff)
  end

  def signed_in?
    current_user.persisted?
  end

  def current_user
    if user_for_authorized_application
      user_for_authorized_application
    elsif session[:staff_id]
      @_current_staff ||= Staff.where(id: session[:staff_id]).first_or_initialize
    elsif session[:patient_id]
      @_current_patient ||= Patient.where(id: session[:patient_id]).first_or_initialize
    else
      Patient.new
    end
  end

  def current_responsible_clinician
    if session[:working_under_id]
      @_current_rc ||= Staff.is?(:physician).where(id: session[:working_under_id]).first
    elsif current_user.is?(:physician)
      @_current_rc ||= current_user
    end
  end

  def redirect_back_or(default = nil, options = {})
    begin
      redirect_to(:back, options)
    rescue ActionController::RedirectBackError
      redirect_to(default || root_path, options)
    end
  end

  def set_last_request_at
    current_user.update_column(:last_request_at, Time.now) if signed_in?
  end

  def initialize_client_side_state
    @client_side_state = {}
  end

  # Save whodunnit's model name and id... avoid saving user details like passwords etc.
  # Also, saves DB space over thousands of edits.
  def user_for_paper_trail
    "#{current_user.class}\##{current_user.id || 'Guest'}"
  end

  def user_for_authorized_application
    return @_api_user if @_api_user
    @_api_user = authenticate_with_http_basic do |k, s|
      u = Staff.where(api_key: k, api_secret: s)
      raise StandardError, "Big problems, duplicate api keys and secrets!" unless u.length <= 1
      u.first
    end
  end

  def set_timezone
    offset = Integer(cookies[:utc_offset], 10) rescue false
    if offset
      tz = ActiveSupport::TimeZone[(-offset * 60)]
      Time.zone = tz if tz
    end
    true
  end

  rescue_from CanCan::AccessDenied do |e|
    logger.info('CanCan::AccessDenied') if Rails.env.development? || Rails.env.staging?
    if current_user.persisted?
      respond_to do |wants|
        wants.html { redirect_back_or root_path, alert: "Sorry, but you don't have access to that." }
        wants.any { head :forbidden }
      end
    else
      session[:referrer] = request.url
      redirect_to new_session_path, alert: 'Please sign in to continue.'
    end
  end

end
