class StampsController < ApplicationController

  before_filter :authorized_to_manage_stamps, except: [ :show ]

  def index
    stamps = Stamp.where('creator_id = ? OR creator_id IS NULL', current_user.id)
    render json: cache(stamps) { Stamp.all }
  end

  private

  def authorized_to_manage_stamps
    authorize! :manage, Stamp
  end

end
