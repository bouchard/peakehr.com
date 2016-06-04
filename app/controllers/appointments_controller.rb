class AppointmentsController < ApplicationController

  def update
    authorize! :update, Appointment
    if @appt = Appointment.where(id: params[:id]).first!
      if params[:status]
        @appt.patient_arrived!(status: params[:status])
        render nothing: true, status: :ok
      else
        render nothing: true, status: :forbidden and return
      end
    end
  end

end
