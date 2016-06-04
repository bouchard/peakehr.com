class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies do |t|

      t.string    :name, null: false
      t.datetime  :start_date, null: false
      t.datetime  :end_date, null: false
      t.text      :description, null: false
      t.string    :consent_form_link, default: nil
      t.string    :study_type, null: false
      t.text      :triggers, null: false
      t.text      :randomize_from, null: false
      t.text      :eligibility_requirements, null: false, default: '[]'

      t.timestamps null: false
    end
  end
end
