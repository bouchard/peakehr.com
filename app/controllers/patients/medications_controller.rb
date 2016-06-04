class Patients::MedicationsController < Patients::BaseController

  def index
    if flash[:print_prescriptions]
      @client_side_state[:print_prescriptions] = flash[:print_prescriptions]
      @client_side_state[:print_prescriptions_path] = patient_prescription_path(@patient, 'NULL', format: :pdf)
    end
  end

  def show
  end

end