class CreateStudyEnrollments < ActiveRecord::Migration
  def change
    create_table :study_enrollments do |t|

      t.integer  :patient_id, null: false
      t.integer  :study_id, null: false
      t.integer  :enrolling_staff_id, null: false
      t.datetime :consent_obtained_at, null: false
      t.string   :randomized_to, null: false

      t.timestamps null: false
    end

    add_index :study_enrollments, :patient_id
    add_index :study_enrollments, :study_id
    add_index :study_enrollments, :enrolling_staff_id
  end
end
