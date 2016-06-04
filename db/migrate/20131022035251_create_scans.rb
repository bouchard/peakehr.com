class CreateScans < ActiveRecord::Migration
  def change
    create_table :scans do |t|

      t.text     :ocr_text, default: nil
      t.integer  :patient_id, null: false
      t.integer  :most_responsible_clinician_id, null: false
      t.integer  :creator_id, null: false
      t.string   :category, null: false
      t.integer  :signed_off_by_id, default: nil
      t.datetime :signed_off_at, default: nil
      t.string   :state, default: nil

      t.timestamps
    end
    add_index :scans, :patient_id
    add_index :scans, :ocr_text
    add_index :scans, :most_responsible_clinician_id
    add_index :scans, :creator_id
    add_index :scans, :category
    add_index :scans, :signed_off_by_id
    add_index :scans, :signed_off_at
    add_index :scans, :state
  end
end
