class ReferenceData < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :"reference_data_#{Rails.env}"

  # Anonymous scope so we can inherit. Lambda's blow up (they maintain current class scope).
  # http://stackoverflow.com/questions/5452910/named-scopes-with-inheritance-in-rails-3-mapping-to-wrong-table
  def self.isearch(h)
    where([ h.map{ |k,v| "#{k} ILIKE ?" }.join(" OR "), h.values.map{ |v| "%#{v}%" } ].flatten)
  end
end