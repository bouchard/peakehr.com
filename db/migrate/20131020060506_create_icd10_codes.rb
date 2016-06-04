class CreateIcd10Codes < ActiveRecord::Migration
  def connection
    Icd10Code.connection
  end
  def change
    create_table :icd10_codes do |t|

      t.text    :description,   null: false
      t.string  :code,          default: nil
      t.integer :synonym_of_id, default: nil

      t.timestamps
    end
    add_index :icd10_codes, :description
    # Can't use a unique index for code as we have lots of null codes.
    # Enforce this on the model instead.
    add_index :icd10_codes, :code
  end
end
