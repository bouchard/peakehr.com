class EncountersController < ApplicationController

  def create
    head :bad_request and return unless params[:patient_id] && params[:content] && patient = Patient.where(id: params[:patient_id]).first
    authorize! :manage, Encounter
    params[:responsible_clinician_id] = current_responsible_clinician.id
    encounter = patient.encounters.create!(
      params
        .slice(:content, :responsible_clinician_id)
        .permit(:content, :responsible_clinician_id)
    )
    render json: { id: encounter.id, title: encounter.title }
  end

  def update
    head :bad_request and return unless params[:content] && params[:content].length > 0 && patient = Patient.where(id: params[:patient_id]).first
    head :not_found and return unless encounter = patient.encounters.where(id: params[:id]).first
    authorize! :manage, encounter
    encounter.update_attributes!(params.slice(:content).permit(:content))
    head :ok
  end

  def sign_off
    head :not_found and return unless encounter = Encounter.where(id: params[:id]).first
    authorize! :sign_off, encounter
    encounter.sign_off!(current_user)
    head :ok
  end

end
