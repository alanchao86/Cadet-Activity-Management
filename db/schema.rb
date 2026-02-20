# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 20_260_220_070_000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'active_storage_attachments', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'record_type', null: false
    t.bigint 'record_id', null: false
    t.bigint 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness', unique: true
  end

  create_table 'active_storage_blobs', force: :cascade do |t|
    t.string 'key', null: false
    t.string 'filename', null: false
    t.string 'content_type'
    t.text 'metadata'
    t.string 'service_name', null: false
    t.bigint 'byte_size', null: false
    t.string 'checksum'
    t.datetime 'created_at', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_variant_records', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.string 'variation_digest', null: false
    t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end

  create_table 'activity_histories', force: :cascade do |t|
    t.bigint 'training_activity_id', null: false
    t.string 'event'
    t.text 'comment'
    t.bigint 'user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['training_activity_id'], name: 'index_activity_histories_on_training_activity_id'
    t.index ['user_id'], name: 'index_activity_histories_on_user_id'
  end

  create_table 'competencies', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'competencies_training_activities', id: false, force: :cascade do |t|
    t.bigint 'training_activity_id'
    t.bigint 'competency_id'
    t.index ['competency_id'], name: 'index_competencies_training_activities_on_competency_id'
    t.index ['training_activity_id'], name: 'index_competencies_training_activities_on_training_activity_id'
  end

  create_table 'training_activities', force: :cascade do |t|
    t.string 'name'
    t.string 'activity_type'
    t.text 'description'
    t.string 'status'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.date 'date'
    t.string 'time'
    t.string 'location'
    t.string 'priority'
    t.text 'justification'
    t.string 'user_id'
    t.integer 'unit_id'
  end

  create_table 'training_activity_status_logs', force: :cascade do |t|
    t.integer 'training_activity_id'
    t.string 'status'
    t.string 'updated_by'
    t.string 'reason'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'units', force: :cascade do |t|
    t.string 'name'
    t.string 'cat'
    t.string 'email'
    t.integer 'parent_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email'
    t.string 'first_name'
    t.string 'last_name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'uid'
    t.string 'provider'
    t.integer 'unit_id'
    t.string 'profile_picture'
    t.boolean 'admin_flag'
    t.string 'major'
    t.string 'minor'
    t.string 'unit_name'
    t.string 'username'
    t.string 'password_digest'
    t.index 'lower((username)::text)', name: 'index_users_on_lower_username', unique: true, where: '(username IS NOT NULL)'
    t.index ['email'], name: 'index_users_on_email', unique: true
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'activity_histories', 'training_activities'
  add_foreign_key 'activity_histories', 'users'
  add_foreign_key 'competencies_training_activities', 'competencies'
  add_foreign_key 'competencies_training_activities', 'training_activities'
end
