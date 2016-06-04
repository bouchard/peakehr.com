class CreateLabResults < ActiveRecord::Migration
  def change
    create_table :lab_results do |t|

      t.integer  :patient_id, null: false
      t.text     :serialized_results, null: false
      t.integer  :most_responsible_clinician_id, null: false
      t.string   :category, null: false
      t.integer  :signed_off_by_id, default: nil
      t.datetime :signed_off_at, default: nil
      t.string   :state, default: nil
      t.text     :comments

      t.timestamps
    end
    add_index :lab_results, :patient_id
    add_index :lab_results, :most_responsible_clinician_id
    add_index :lab_results, :category
    add_index :lab_results, :signed_off_by_id
    add_index :lab_results, :signed_off_at
    add_index :lab_results, :state
    add_index :lab_results, :serialized_results
  end
end
