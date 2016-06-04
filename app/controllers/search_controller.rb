class SearchController < ApplicationController

  before_filter :authorized_to_view_patient

  def autocomplete
    head :bad_request and return unless s = params[:s]
    json = cache [ 'v1', s, 'search-query', Time.now.to_i / 1.minute ] do
      s.downcase!
      search_type = :all
      begin
        d = Date.parse(s)
        search_type = :date
      rescue ArgumentError
      end
      s.match(/^pa?t?i?e?n?t?s:(.+)$/) do |m|
        logger.info(m.inspect)
      end
      s.match(/^do?b?:(.+)$/) do |m|
        logger.info(m.inspect)
      end
      s.match(/^d?a?t?e?.+:(.+)$/) do |m|
        logger.info(m.inspect)
      end
      first_name = last_name = s
      patients = Patient.where("first_name ILIKE ? OR last_name ILIKE ?", "%#{first_name}%", "%#{last_name}%").limit(10)
      {
        suggestions: patients.map{ |p|
          {
            value: p.full_name,
            data: p.id,
            url: "/patients/#{p.id}"
          }
        }
      }
    end
    render json: json
  end

  private

  def authorized_to_view_patient
    authorize! :view, Patient
  end

end
