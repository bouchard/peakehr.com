class LettersController < ApplicationController

  def show
    @letter = Letter.where(id: params[:id]).first!
    authorize! :view, @letter
    respond_to do |wants|
      wants.pdf do
        pdf = cache([ @letter, 'pdf' ]) { @letter.to_pdf }
        send_data pdf, type: :pdf, disposition: :inline, filename: "#{@letter.id}.pdf"
      end
      wants.png do
        png = cache([ @letter, 'png' ]) { @letter.to_png }
        send_data png, type: :png, disposition: :inline, filename: "#{@letter.id}.png"
      end
    end
  end

  def create
    head :bad_request and return unless params[:patient_id] && params[:to_address] && params[:content] && patient = Patient.where(id: params[:patient_id]).first
    authorize! :manage, Letter
    params[:creator_id] = current_user.id
    letter = patient.letters.create!(
      params
        .slice(:to_address, :content, :creator_id)
        .permit(:to_address, :content, :creator_id)
    )
    render json: { id: letter.id, title: letter.title }
  end

  def update
    head :bad_request and return unless params[:patient_id] && params[:to_address] && params[:content] && patient = Patient.where(id: params[:patient_id]).first
    head :not_found and return unless letter = patient.letters.where(id: params[:id]).first
    authorize! :manage, letter
    letter.update_attributes!(params.slice(:to_address, :content).permit(:to_address, :content))
    render json: { title: letter.title }
  end

  def sign_off
    head :not_found and return unless encounter = Encounter.where(id: params[:id]).first
    authorize! :sign_off, encounter
    encounter.sign_off!(current_user)
    head :ok
  end

end
