class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|

      t.string   :title
      t.text     :comment
      t.integer  :patient_id, null: false
      t.integer  :creator_id, null: false
      t.integer  :assigned_to_id, null: false
      t.datetime :actioned_at, default: nil
      t.date     :due_date

      t.timestamps
    end
    add_index :tasks, :patient_id
    add_index :tasks, :creator_id
    add_index :tasks, :assigned_to_id
  end
end
