class CreateMedications < ActiveRecord::Migration
  def change
    create_table :medications do |t|

      t.integer  :patient_id,               null: false
      # Initiator is null if an external script.
      t.boolean  :ongoing,                  default: true
      t.boolean  :external,                 default: false
      t.string   :name,                     null: false
      t.datetime :discontinued_at,          default: nil
      t.text     :discontinued_reason
      t.integer  :discontinued_by
      t.integer  :drug_id,                  default: nil

      t.timestamps
    end
    add_index :medications, :patient_id
    add_index :medications, :ongoing
    add_index :medications, :external
    add_index :medications, :name
    add_index :medications, :discontinued_at
    add_index :medications, :drug_id
    add_index :medications, [ :name, :patient_id ], unique: true

  end
end
