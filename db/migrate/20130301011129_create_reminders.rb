class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|

      t.string   :title
      t.text     :comment
      t.integer  :patient_id, null: false
      t.integer  :creator_id, default: nil
      t.datetime :actioned_at, default: nil
      t.datetime :actionable_after, default: nil
      t.string   :based_on_screening_recommendation, default: nil

      t.timestamps
    end
    add_index :reminders, :patient_id
    add_index :reminders, :creator_id
  end
end
