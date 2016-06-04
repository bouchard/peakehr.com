class StaffController < ApplicationController

  before_filter :load_staff
  before_filter :authorized_to_manage_staff

  def show
  end

  private

  def load_staff
    @staff = staff.where(id: params[:id]).first!
  end

  def authorized_to_manage_staff
    @staff == current_staff || authorize!(:manage, @staff)
  end

end
