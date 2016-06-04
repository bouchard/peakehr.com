class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|

      t.integer  :patient_id, null: false
      t.integer  :workday_id, null: false
      t.integer  :staff_id, null: false
      t.datetime :booked_at, null: false
      t.integer  :length_in_seconds, null: false
      t.string   :one_liner

      t.timestamps
    end

    add_index :appointments, :patient_id
    add_index :appointments, :staff_id
    add_index :appointments, :workday_id
  end
end
