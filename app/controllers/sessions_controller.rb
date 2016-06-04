class SessionsController < ApplicationController

 def new
   redirect_to schedule_path if signed_in?
 end

 def create
   if session[:needing_otp_staff_id]
     logger.info("Log: needing_otp_staff_id")
     u = Staff.where(id: session[:needing_otp_staff_id]).first!
     if u.authenticate_otp(params[:user][:otp_token], drift: 60)
       session.delete(:needing_otp_staff_id)
       session[:staff_id] = u.id
       if params[:user][:trust_this_computer] == '1'
         cookies.signed[:trusted_until] = 30.days.from_now
       end
       redirect_to schedule_path
     else
       redirect_to new_session_path, alert: 'Incorrect authentication token.'
     end
   elsif u = Staff.authenticate(params[:user].slice(:username, :password))
     logger.info("Passed user authenticate")
     if trusted_computer? || !TWO_FACTOR_AUTHENTICATION
       logger.info("Passed trusted_computer? || TWO_FACTOR_AUTHENTICATION")
       session[:staff_id] = u.id
       redirect_to session.delete(:referrer) || root_path
     else
       logger.info("Assigning needing_otp_staff_id")
       session[:needing_otp_staff_id] = u.id
       redirect_to new_session_path
     end
   else
     redirect_to new_session_path, alert: 'Incorrect username or password.'
   end
 end

 def set_working_under
   head :bad_request and return unless params[:working_under_id] && u = Staff.where(id: params[:working_under_id]).first
   head :bad_request and return unless Ability.new(u).can?(:be_most_responsible_for, :all)
   session[:working_under_id] = u.id
   head :ok
 end

 def destroy
   session[:staff_id] = nil
   redirect_to new_session_path, notice: 'You have been signed out.'
 end

 def setup_otp
   redirect_back_or and return unless session[:needing_otp_staff_id] && u = Staff.where(id: session[:needing_otp_staff_id]).first
 end

 def otp_qrcode
   if session[:needing_otp_staff_id] && u = Staff.where(id: session[:needing_otp_staff_id]).first
     respond_to do |format|
       format.svg { render qrcode: u.provisioning_uri("#{u.username}@peakehr.com"), level: :m, unit: 5 }
     end
   else
     render nothing: true, status: :not_found
   end
 end

 def setup_api_tokens
 end

 def api_tokens_qrcode
   authorize! :pair_mobile, current_user
    respond_to do |format|
      format.svg { render qrcode: { hostname: request.host, key: current_user.api_key, secret: current_user.api_secret }.to_json, level: :m, unit: 5 }
    end
 end

 def api_auth_test
   if user_for_authorized_application
     EventSource.publish('mobile_paired', { id: user_for_authorized_application.id })
     head :ok
   else
     head :forbidden
   end
 end

end