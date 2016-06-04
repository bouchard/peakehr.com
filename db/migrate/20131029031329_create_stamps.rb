class CreateStamps < ActiveRecord::Migration
  def change
    create_table :stamps do |t|

      t.string :title
      t.text   :body
      t.integer :creator_id, default: nil

      t.timestamps
    end
    add_index :stamps, :creator_id
  end
end
