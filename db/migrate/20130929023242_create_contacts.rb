class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|

      t.string  :name
      t.string  :default_addressee
      t.text    :address
      t.string  :email
      t.string  :fax_number
      t.string  :phone_number

      t.timestamps
    end
  end
end
