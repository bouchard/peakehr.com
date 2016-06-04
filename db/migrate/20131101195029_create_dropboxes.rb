class CreateDropboxes < ActiveRecord::Migration
  def change
    create_table :dropboxes do |t|
      t.integer :encounter_id, null: false
      t.string  :code, null: false

      t.timestamps
    end
    add_index :dropboxes, :code
    add_index :dropboxes, [ :id, :encounter_id ], unique: true
  end
end
