class CreateWorkdays < ActiveRecord::Migration
  def change
    create_table :workdays do |t|

      t.string  :office_hour_intervals_in_seconds, null: false
      t.integer :staff_id,                          null: false
      t.date    :date,                             null: false

      t.timestamps
    end

    add_index :workdays, :office_hour_intervals_in_seconds
    add_index :workdays, :staff_id
    add_index :workdays, [ :staff_id, :date ], unique: true
  end
end
