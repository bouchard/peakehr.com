class CreateDrugs < ActiveRecord::Migration
  def connection
    Drug.connection
  end
  def change
    create_table :drugs do |t|

      t.string :identifier
      t.string :name
      t.string :form
      t.string :route
      t.string :schedule
      t.string :drug_class
      t.string :suggested_dose_range

      t.timestamps
    end
    add_index :drugs, :identifier, unique: true
  end
end
