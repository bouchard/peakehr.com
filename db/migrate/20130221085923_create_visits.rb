class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|

      t.integer  :appointment_id, null: false
      t.datetime :start_time
      t.datetime :end_time
      t.integer  :duration_in_seconds
      t.boolean  :completed, default: false

      t.timestamps
    end

    add_index :visits, :appointment_id
    add_index :visits, :completed
  end
end
