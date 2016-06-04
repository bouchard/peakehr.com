class CreateEncounters < ActiveRecord::Migration
  def change
    create_table :encounters do |t|

      t.integer   :patient_id, null: false
      t.text      :content
      t.integer   :signed_off_by_id, default: nil
      t.string    :state, default: nil
      t.datetime  :signed_off_at, default: nil
      t.integer   :responsible_clinician_id, default: nil
      t.integer   :icd10_code_id

      t.timestamps
    end

    add_index :encounters, :patient_id
    add_index :encounters, :signed_off_by_id
    add_index :encounters, :signed_off_at
    add_index :encounters, :state
    add_index :encounters, :responsible_clinician_id
    add_index :encounters, :icd10_code_id
  end
end
