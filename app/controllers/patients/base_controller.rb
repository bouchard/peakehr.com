class Patients::BaseController < ApplicationController

  before_filter :load_patient

  private

  def load_patient
    authorize! :view, Patient
    begin
      @patient = Patient.where(id: params[:patient_id]).first!
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end
  end

end