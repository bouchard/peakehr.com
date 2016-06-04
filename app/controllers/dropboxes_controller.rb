class DropboxesController < ApplicationController

  def create
    @encounter = Encounter.where(id: params[:encounter_id]).first!
    authorize! :update, @encounter
    d = @encounter.dropbox
    d && d.inactive? && d.destroy && @encounter.reload
    d = @encounter.dropbox || @encounter.create_dropbox
    d.touch
    render json: { id: d.id, code: d.code.upcase, email_address: current_user.dropbox_email_address }
  end

end
