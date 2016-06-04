class CreatePrescriptions < ActiveRecord::Migration
  def change
    create_table :prescriptions do |t|

      t.integer  :medication_id,       null: false
      t.string   :dose_and_route,      null: false
      t.integer  :prescriber_id,       null: false
      t.integer  :duration_integer,    null: false
      t.integer  :duration_multiplier, null: false
      t.integer  :refills,             default: 0, null: false
      t.date     :start_date,          null: false
      t.date     :expiry_date,         null: false
      t.date     :valid_until,         null: false
      t.boolean  :signed_off,          default: false
      t.string   :comment

      t.timestamps
    end

    add_index :prescriptions, :prescriber_id
    add_index :prescriptions, :medication_id
    add_index :prescriptions, :start_date
    add_index :prescriptions, :expiry_date
  end
end
