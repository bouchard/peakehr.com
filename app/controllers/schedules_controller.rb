class SchedulesController < ApplicationController

  before_filter :authorized_to_manage_schedule

  def show
    # session[:clinicians_to_show] ||= [ current_user ].map(&:id)
    session[:clinicians_to_show] = [ current_user, Staff.all.select{ |u| u.role == :physician }[0..2] ].flatten.map(&:id).uniq
    @date = Time.parse(params[:s]).to_date rescue Date.today
    @calendars = session[:clinicians_to_show].map do |c|
      Calendar.new(clinician_id: c, date: @date)
    end
  end

  def daysheet
    @date = Time.parse(params[:s]).to_date rescue Date.today
    @calendars = (1..4).map do |c|
      Calendar.new(clinician_id: current_user, date: @date - (@date.wday + c).days)
    end
    render :show
  end

  def add_clinician
    session[:clinicians_to_show] ||= []
    session[:clinicians_to_show] << c.id if c = Staff.physician.where(id: params[:id]).first!
    redirect_back_or
  end

  private

  def authorized_to_manage_schedule
    authorize! :manage, :schedule
  end

end
