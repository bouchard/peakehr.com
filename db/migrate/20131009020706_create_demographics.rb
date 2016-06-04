class CreateDemographics < ActiveRecord::Migration
  def change
    create_table :demographics do |t|

      t.integer  :patient_id, null: false
      t.date     :date_of_birth
      t.string   :sex
      t.string   :occupation
      t.text     :addresses
      t.text     :phone_numbers

      t.timestamps
    end
    add_index :demographics, :date_of_birth
    add_index :demographics, :sex
    add_index :demographics, :occupation
  end
end
