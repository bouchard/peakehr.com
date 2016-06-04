class Patients::PrescriptionsController < Patients::BaseController

  def new
    @prescription = @patient.prescriptions.new(new_prescription_params)
  end

  def create
    @medication = @patient.medications.where(name: prescription_params[:name].upcase).first_or_create!
    if @prescription = @medication.prescribe!(prescription_params.merge({
      prescriber: current_user
    }))
      flash[:print_prescriptions] = @prescription.id if params[:commit].match(/print/i)
      redirect_to patient_medications_path(@patient)
    else
      render :new
    end
  end

  def show
    ids = params[:id].split(',').join('-').split('-').map(&:to_i)
    prescriptions = @patient.prescriptions.where(id: ids)
    prescriptions.each { |p| authorize! :view, p }
    respond_to do |wants|
      wants.pdf do
        pdf = cache([ prescriptions, 'pdf' ]) { Prescription.to_pdf(prescriptions) }
        send_data pdf, type: :pdf, disposition: :inline, filename: "Prescription-#{prescriptions.map(&:id).join('-')}.pdf"
      end
    end
  end

  def autocomplete
    head :bad_request and return unless s = params[:s]
    json = cache [ 'v1', s, @patient.id, 'prescription-query', Time.now.to_i / 1.hour ] do
      s.downcase!
      drugs = Drug.where("name ILIKE ?", "%#{s}%").limit(10)
      {
        suggestions: drugs.map{ |d|
          {
            value: d.name,
            data: d.id
          }
        }
      }
    end
    render json: json
  end

  def check_suggested_dosing
    head :bad_request and return unless s = params[:drug]
    drug = Drug.where(name: params[:drug].upcase).first!
    render json: { suggested_dose_range: drug.suggested_dose_range }
  end

  private

  def new_prescription_params
    params[:prescription].nil? ? {} : params[:prescription].permit(:name)
  end

  def prescription_params
    params.require(:prescription).permit(
      :name, :dose_and_route, :duration_integer,
      :duration_multiplier, :comment, :pretty_start_date,
      :refills
    )
  end

end