class CreateLetters < ActiveRecord::Migration
  def change
    create_table :letters do |t|

      t.text     :to_address, null: false
      t.text     :content, null: false
      t.integer  :creator_id, null: false
      t.integer  :patient_id, null: false
      t.string   :state, default: nil
      t.datetime :signed_off_at, default: nil
      t.integer  :sent_by_id, default: nil
      t.datetime :sent_at, default: nil

      t.timestamps
    end
    add_index :letters, :creator_id
    add_index :letters, :patient_id
    add_index :letters, :state
  end
end
