class PatientsController < ApplicationController

  before_filter :load_patient

  def show
  end

  private

  def load_patient
    authorize! :view, Patient
    begin
      @patient = Patient.includes(:demographics).includes(:letters).where(id: params[:id]).first!
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end
  end

end
