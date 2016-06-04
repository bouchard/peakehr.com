class SupportController < ApplicationController

  before_filter :must_be_staff

  # TODO
  def index
  end

  def create
    AdminMailer.new_support_request(params).deliver
    destination = params[:referrer] if params[:referrer] && URI(params[:referrer]).host == URI(request.original_url).host
    destination = root_path unless signed_in?
    destination ||= staff_signed_in? ? clinician_root_path : patient_root_path
    redirect_to destination, notice: "Thanks for your comments, we'll be in touch soon."
  end

  def must_be_staff
    head :forbidden and return unless staff_signed_in?
  end

end
