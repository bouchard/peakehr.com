class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|

      t.string   :username, null: false
      t.string   :password_digest, null: false
      t.datetime :last_request_at, default: nil
      t.string   :time_zone, default: 'Saskatchewan'
      t.string   :chart_id
      t.string   :health_number
      t.string   :first_name
      t.string   :last_name
      t.integer  :most_responsible_clinician_id, null: false

      t.timestamps
    end

    add_index :patients, :chart_id
    add_index :patients, :health_number
    add_index :patients, :first_name
    add_index :patients, :last_name
    add_index :patients, :most_responsible_clinician_id
    add_index :patients, :username, unique: true
  end
end
