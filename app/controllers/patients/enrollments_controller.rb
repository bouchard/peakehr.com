class Patients::EnrollmentsController < Patients::BaseController

  before_filter :load_study, :except => [ :check_eligibility ]

  # New Patient Enrollment.
  # Present consent form for printing, needs to be scanned into patient
  # chart.
  def new
    @study_enrollment = @patient.study_enrollments.build(study: @study)
  end

  def create
    @study_enrollment = @patient.study_enrollments.build(enrollment_params)
    if @study_enrollment.save
      d = @study_enrollment.randomized_to
      redirect_to(new_patient_prescription_path(prescription: { name: d }), notice: "Your patient has been randomized to #{d.upcase}")
      return
    else
      render :new
    end
  end

  def check_eligibility
    trigger = params[:trigger]
    study_type = params[:study_type] # Intention to treat, etc.
    value = params[:value]
    if trigger == 'new_prescription'
      current_study = Study.match_study_type_and_drug(study_type, value)
      render json: current_study and return unless current_study.nil?
    end
    head :bad_request
  end

  private

  def load_study
    authorize! :view, Patient
    begin
      @study = Study.where(id: params[:study_id]).first!
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end
  end

  def enrollment_params
    params.require(:study_enrollment).permit(:consent_obtained).merge(study: @study, enrolling_staff: current_user)
  end

end