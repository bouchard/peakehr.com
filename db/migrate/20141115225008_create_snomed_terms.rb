class CreateSnomedTerms < ActiveRecord::Migration
  def connection
    SnomedTerm.connection
  end
  def change
    create_table :snomed_terms do |t|

      t.text    :description, null: false
      t.string  :code,        null: false

      t.timestamps
    end
    add_index :snomed_terms, :description
    add_index :snomed_terms, :code
  end
end
