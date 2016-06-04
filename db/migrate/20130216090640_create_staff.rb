class CreateStaff < ActiveRecord::Migration
  def change
    create_table :staff do |t|

      t.string    :username, null: false
      t.string    :password_digest, null: false
      t.string    :title
      t.string    :first_name
      t.string    :last_name
      t.string    :suffix
      t.string    :roles, default: nil
      t.datetime  :last_request_at, default: nil
      t.string    :time_zone, default: 'Saskatchewan'
      t.string    :default_letter_greeting, default: 'Dear'
      t.string    :default_letter_closing, default: 'Kind regards,'
      t.string    :dropbox_email_prefix, null: false
      t.string    :api_key, null: false
      t.string    :api_secret, null: false
      # For One Time Password (2FA)
      t.string    :otp_secret_key, null: false

      t.timestamps
    end

    add_index :staff, :username, unique: true
    add_index :staff, :dropbox_email_prefix, unique: true
    add_index :staff, :api_key
  end
end