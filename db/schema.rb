# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150225011905) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.integer  "patient_id",        null: false
    t.integer  "workday_id",        null: false
    t.integer  "staff_id",          null: false
    t.datetime "booked_at",         null: false
    t.integer  "length_in_seconds", null: false
    t.string   "one_liner"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "appointments", ["patient_id"], name: "index_appointments_on_patient_id", using: :btree
  add_index "appointments", ["staff_id"], name: "index_appointments_on_staff_id", using: :btree
  add_index "appointments", ["workday_id"], name: "index_appointments_on_workday_id", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["attachable_id"], name: "index_attachments_on_attachable_id", using: :btree
  add_index "attachments", ["attachable_type"], name: "index_attachments_on_attachable_type", using: :btree

  create_table "conditions", force: :cascade do |t|
    t.integer  "patient_id",   null: false
    t.string   "name"
    t.text     "details"
    t.date     "diagnosed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conditions", ["patient_id"], name: "index_conditions_on_patient_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.string   "name"
    t.string   "default_addressee"
    t.text     "address"
    t.string   "email"
    t.string   "fax_number"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "demographics", force: :cascade do |t|
    t.integer  "patient_id",    null: false
    t.date     "date_of_birth"
    t.string   "sex"
    t.string   "occupation"
    t.text     "addresses"
    t.text     "phone_numbers"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "demographics", ["date_of_birth"], name: "index_demographics_on_date_of_birth", using: :btree
  add_index "demographics", ["occupation"], name: "index_demographics_on_occupation", using: :btree
  add_index "demographics", ["sex"], name: "index_demographics_on_sex", using: :btree

  create_table "dropboxes", force: :cascade do |t|
    t.integer  "encounter_id", null: false
    t.string   "code",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dropboxes", ["code"], name: "index_dropboxes_on_code", using: :btree
  add_index "dropboxes", ["id", "encounter_id"], name: "index_dropboxes_on_id_and_encounter_id", unique: true, using: :btree

  create_table "encounters", force: :cascade do |t|
    t.integer  "patient_id",               null: false
    t.text     "content"
    t.integer  "signed_off_by_id"
    t.string   "state"
    t.datetime "signed_off_at"
    t.integer  "responsible_clinician_id"
    t.integer  "icd10_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "encounters", ["icd10_code_id"], name: "index_encounters_on_icd10_code_id", using: :btree
  add_index "encounters", ["patient_id"], name: "index_encounters_on_patient_id", using: :btree
  add_index "encounters", ["responsible_clinician_id"], name: "index_encounters_on_responsible_clinician_id", using: :btree
  add_index "encounters", ["signed_off_at"], name: "index_encounters_on_signed_off_at", using: :btree
  add_index "encounters", ["signed_off_by_id"], name: "index_encounters_on_signed_off_by_id", using: :btree
  add_index "encounters", ["state"], name: "index_encounters_on_state", using: :btree

  create_table "lab_results", force: :cascade do |t|
    t.integer  "patient_id",                    null: false
    t.text     "serialized_results",            null: false
    t.integer  "most_responsible_clinician_id", null: false
    t.string   "category",                      null: false
    t.integer  "signed_off_by_id"
    t.datetime "signed_off_at"
    t.string   "state"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lab_results", ["category"], name: "index_lab_results_on_category", using: :btree
  add_index "lab_results", ["most_responsible_clinician_id"], name: "index_lab_results_on_most_responsible_clinician_id", using: :btree
  add_index "lab_results", ["patient_id"], name: "index_lab_results_on_patient_id", using: :btree
  add_index "lab_results", ["serialized_results"], name: "index_lab_results_on_serialized_results", using: :btree
  add_index "lab_results", ["signed_off_at"], name: "index_lab_results_on_signed_off_at", using: :btree
  add_index "lab_results", ["signed_off_by_id"], name: "index_lab_results_on_signed_off_by_id", using: :btree
  add_index "lab_results", ["state"], name: "index_lab_results_on_state", using: :btree

  create_table "letters", force: :cascade do |t|
    t.text     "to_address",    null: false
    t.text     "content",       null: false
    t.integer  "creator_id",    null: false
    t.integer  "patient_id",    null: false
    t.string   "state"
    t.datetime "signed_off_at"
    t.integer  "sent_by_id"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "letters", ["creator_id"], name: "index_letters_on_creator_id", using: :btree
  add_index "letters", ["patient_id"], name: "index_letters_on_patient_id", using: :btree
  add_index "letters", ["state"], name: "index_letters_on_state", using: :btree

  create_table "medications", force: :cascade do |t|
    t.integer  "patient_id",                          null: false
    t.boolean  "ongoing",             default: true
    t.boolean  "external",            default: false
    t.string   "name",                                null: false
    t.datetime "discontinued_at"
    t.text     "discontinued_reason"
    t.integer  "discontinued_by"
    t.integer  "drug_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "medications", ["discontinued_at"], name: "index_medications_on_discontinued_at", using: :btree
  add_index "medications", ["drug_id"], name: "index_medications_on_drug_id", using: :btree
  add_index "medications", ["external"], name: "index_medications_on_external", using: :btree
  add_index "medications", ["name", "patient_id"], name: "index_medications_on_name_and_patient_id", unique: true, using: :btree
  add_index "medications", ["name"], name: "index_medications_on_name", using: :btree
  add_index "medications", ["ongoing"], name: "index_medications_on_ongoing", using: :btree
  add_index "medications", ["patient_id"], name: "index_medications_on_patient_id", using: :btree

  create_table "patients", force: :cascade do |t|
    t.string   "username",                                               null: false
    t.string   "password_digest",                                        null: false
    t.datetime "last_request_at"
    t.string   "time_zone",                     default: "Saskatchewan"
    t.string   "chart_id"
    t.string   "health_number"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "most_responsible_clinician_id",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "patients", ["chart_id"], name: "index_patients_on_chart_id", using: :btree
  add_index "patients", ["first_name"], name: "index_patients_on_first_name", using: :btree
  add_index "patients", ["health_number"], name: "index_patients_on_health_number", using: :btree
  add_index "patients", ["last_name"], name: "index_patients_on_last_name", using: :btree
  add_index "patients", ["most_responsible_clinician_id"], name: "index_patients_on_most_responsible_clinician_id", using: :btree
  add_index "patients", ["username"], name: "index_patients_on_username", unique: true, using: :btree

  create_table "prescriptions", force: :cascade do |t|
    t.integer  "medication_id",                       null: false
    t.string   "dose_and_route",                      null: false
    t.integer  "prescriber_id",                       null: false
    t.integer  "duration_integer",                    null: false
    t.integer  "duration_multiplier",                 null: false
    t.integer  "refills",             default: 0,     null: false
    t.date     "start_date",                          null: false
    t.date     "expiry_date",                         null: false
    t.date     "valid_until",                         null: false
    t.boolean  "signed_off",          default: false
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prescriptions", ["expiry_date"], name: "index_prescriptions_on_expiry_date", using: :btree
  add_index "prescriptions", ["medication_id"], name: "index_prescriptions_on_medication_id", using: :btree
  add_index "prescriptions", ["prescriber_id"], name: "index_prescriptions_on_prescriber_id", using: :btree
  add_index "prescriptions", ["start_date"], name: "index_prescriptions_on_start_date", using: :btree

  create_table "reminders", force: :cascade do |t|
    t.string   "title"
    t.text     "comment"
    t.integer  "patient_id",                        null: false
    t.integer  "creator_id"
    t.datetime "actioned_at"
    t.datetime "actionable_after"
    t.string   "based_on_screening_recommendation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reminders", ["creator_id"], name: "index_reminders_on_creator_id", using: :btree
  add_index "reminders", ["patient_id"], name: "index_reminders_on_patient_id", using: :btree

  create_table "scans", force: :cascade do |t|
    t.text     "ocr_text"
    t.integer  "patient_id",                    null: false
    t.integer  "most_responsible_clinician_id", null: false
    t.integer  "creator_id",                    null: false
    t.string   "category",                      null: false
    t.integer  "signed_off_by_id"
    t.datetime "signed_off_at"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scans", ["category"], name: "index_scans_on_category", using: :btree
  add_index "scans", ["creator_id"], name: "index_scans_on_creator_id", using: :btree
  add_index "scans", ["most_responsible_clinician_id"], name: "index_scans_on_most_responsible_clinician_id", using: :btree
  add_index "scans", ["ocr_text"], name: "index_scans_on_ocr_text", using: :btree
  add_index "scans", ["patient_id"], name: "index_scans_on_patient_id", using: :btree
  add_index "scans", ["signed_off_at"], name: "index_scans_on_signed_off_at", using: :btree
  add_index "scans", ["signed_off_by_id"], name: "index_scans_on_signed_off_by_id", using: :btree
  add_index "scans", ["state"], name: "index_scans_on_state", using: :btree

  create_table "staff", force: :cascade do |t|
    t.string   "username",                                          null: false
    t.string   "password_digest",                                   null: false
    t.string   "title"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "suffix"
    t.string   "roles"
    t.datetime "last_request_at"
    t.string   "time_zone",               default: "Saskatchewan"
    t.string   "default_letter_greeting", default: "Dear"
    t.string   "default_letter_closing",  default: "Kind regards,"
    t.string   "dropbox_email_prefix",                              null: false
    t.string   "api_key",                                           null: false
    t.string   "api_secret",                                        null: false
    t.string   "otp_secret_key",                                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "staff", ["api_key"], name: "index_staff_on_api_key", using: :btree
  add_index "staff", ["dropbox_email_prefix"], name: "index_staff_on_dropbox_email_prefix", unique: true, using: :btree
  add_index "staff", ["username"], name: "index_staff_on_username", unique: true, using: :btree

  create_table "stamps", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stamps", ["creator_id"], name: "index_stamps_on_creator_id", using: :btree

  create_table "studies", force: :cascade do |t|
    t.string   "name",                                    null: false
    t.datetime "start_date",                              null: false
    t.datetime "end_date",                                null: false
    t.text     "description",                             null: false
    t.string   "consent_form_link"
    t.string   "study_type",                              null: false
    t.text     "triggers",                                null: false
    t.text     "randomize_from",                          null: false
    t.text     "eligibility_requirements", default: "[]", null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "study_enrollments", force: :cascade do |t|
    t.integer  "patient_id",          null: false
    t.integer  "study_id",            null: false
    t.integer  "enrolling_staff_id",  null: false
    t.datetime "consent_obtained_at", null: false
    t.string   "randomized_to",       null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "study_enrollments", ["enrolling_staff_id"], name: "index_study_enrollments_on_enrolling_staff_id", using: :btree
  add_index "study_enrollments", ["patient_id"], name: "index_study_enrollments_on_patient_id", using: :btree
  add_index "study_enrollments", ["study_id"], name: "index_study_enrollments_on_study_id", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "title"
    t.text     "comment"
    t.integer  "patient_id",     null: false
    t.integer  "creator_id",     null: false
    t.integer  "assigned_to_id", null: false
    t.datetime "actioned_at"
    t.date     "due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["assigned_to_id"], name: "index_tasks_on_assigned_to_id", using: :btree
  add_index "tasks", ["creator_id"], name: "index_tasks_on_creator_id", using: :btree
  add_index "tasks", ["patient_id"], name: "index_tasks_on_patient_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "visits", force: :cascade do |t|
    t.integer  "appointment_id",                      null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "duration_in_seconds"
    t.boolean  "completed",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "visits", ["appointment_id"], name: "index_visits_on_appointment_id", using: :btree
  add_index "visits", ["completed"], name: "index_visits_on_completed", using: :btree

  create_table "workdays", force: :cascade do |t|
    t.string   "office_hour_intervals_in_seconds", null: false
    t.integer  "staff_id",                         null: false
    t.date     "date",                             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workdays", ["office_hour_intervals_in_seconds"], name: "index_workdays_on_office_hour_intervals_in_seconds", using: :btree
  add_index "workdays", ["staff_id", "date"], name: "index_workdays_on_staff_id_and_date", unique: true, using: :btree
  add_index "workdays", ["staff_id"], name: "index_workdays_on_staff_id", using: :btree

end
