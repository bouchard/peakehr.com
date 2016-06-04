class Patients::DemographicsController < Patients::BaseController

  def show
    @demographics = @patient.demographics
    @enrollments = @patient.study_enrollments
  end

end
