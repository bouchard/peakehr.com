class CreateConditions < ActiveRecord::Migration
  def change
    create_table :conditions do |t|

      t.integer   :patient_id, null: false
      t.string    :name
      t.text      :details
      t.date      :diagnosed_at

      t.timestamps
    end

    add_index :conditions, :patient_id
  end
end
