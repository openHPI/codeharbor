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

ActiveRecord::Schema[7.1].define(version: 2024_05_31_160738) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "account_link_users", force: :cascade do |t|
    t.integer "account_link_id", null: false
    t.integer "user_id", null: false
    t.index ["account_link_id", "user_id"], name: "index_account_link_users_on_account_link_id_and_user_id"
  end

  create_table "account_links", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "push_url"
    t.integer "user_id"
    t.string "api_key"
    t.string "name"
    t.string "check_uuid_url"
    t.index ["user_id"], name: "index_account_links_on_user_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "collection_tasks", force: :cascade do |t|
    t.bigint "task_id"
    t.bigint "collection_id"
    t.integer "rank", default: 0, null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["collection_id"], name: "index_collection_tasks_on_collection_id"
    t.index ["task_id"], name: "index_collection_tasks_on_task_id"
  end

  create_table "collection_user_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.bigint "user_id", null: false
    t.index ["collection_id"], name: "index_collection_user_favorites_on_collection_id"
    t.index ["user_id"], name: "index_collection_user_favorites_on_user_id"
  end

  create_table "collection_users", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "collection_id"
    t.index ["collection_id"], name: "index_collection_users_on_collection_id"
    t.index ["user_id"], name: "index_collection_users_on_user_id"
  end

  create_table "collections", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "description", default: "", null: false
    t.integer "visibility_level", limit: 2, default: 0, null: false, comment: "Used as enum in Rails"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "text"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "task_id"
    t.index ["task_id"], name: "index_comments_on_task_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "group_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.integer "role", limit: 2, default: 0, null: false, comment: "Used as enum in Rails"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "group_tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_tasks_on_group_id"
    t.index ["task_id"], name: "index_group_tasks_on_task_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "import_file_caches", force: :cascade do |t|
    t.bigint "user_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_import_file_caches_on_user_id"
  end

  create_table "labels", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
  end

  create_table "licenses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.text "text"
    t.integer "sender_id"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "param_type"
    t.integer "param_id"
    t.string "sender_status", default: "s"
    t.string "recipient_status", default: "u"
  end

  create_table "model_solutions", force: :cascade do |t|
    t.text "description"
    t.text "internal_description"
    t.string "xml_id"
    t.bigint "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_model_solutions_on_task_id"
  end

  create_table "programming_languages", force: :cascade do |t|
    t.string "language"
    t.string "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ratings", id: :serial, force: :cascade do |t|
    t.integer "rating"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "task_id"
    t.index ["task_id"], name: "index_ratings_on_task_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "task_id"
    t.index ["task_id"], name: "index_reports_on_task_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "task_files", force: :cascade do |t|
    t.text "content"
    t.string "path"
    t.string "name"
    t.string "internal_description"
    t.string "mime_type"
    t.boolean "used_by_grader"
    t.string "visible"
    t.string "usage_by_lms"
    t.string "fileable_type"
    t.bigint "fileable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "xml_id"
    t.index ["fileable_type", "fileable_id"], name: "index_task_files_on_fileable_type_and_fileable_id"
  end

  create_table "task_labels", force: :cascade do |t|
    t.integer "label_id"
    t.bigint "task_id"
    t.index ["label_id"], name: "index_task_labels_on_label_id"
    t.index ["task_id"], name: "index_task_labels_on_task_id"
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "internal_description"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "parent_uuid"
    t.string "language"
    t.bigint "programming_language_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "meta_data", default: {}, null: false
    t.bigint "license_id"
    t.integer "access_level", limit: 2, default: 0, null: false, comment: "Used as enum in Rails"
    t.jsonb "submission_restrictions"
    t.jsonb "external_resources"
    t.jsonb "grading_hints"
    t.index ["license_id"], name: "index_tasks_on_license_id"
    t.index ["programming_language_id"], name: "index_tasks_on_programming_language_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "testing_frameworks", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "version"
  end

  create_table "tests", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "description"
    t.text "internal_description"
    t.string "test_type"
    t.string "xml_id"
    t.string "validity"
    t.string "timeout"
    t.bigint "task_id"
    t.jsonb "meta_data"
    t.bigint "testing_framework_id"
    t.jsonb "configuration"
    t.index ["testing_framework_id"], name: "index_tests_on_testing_framework_id"
  end

  create_table "user_identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "omniauth_provider"
    t.string "provider_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["omniauth_provider", "provider_uid"], name: "index_user_identities_on_omniauth_provider_and_provider_uid", unique: true
    t.index ["user_id"], name: "index_user_identities_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.boolean "deleted"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "preferred_locale"
    t.boolean "password_set", default: true, null: false
    t.integer "status_group", limit: 1, default: 0, null: false, comment: "Used as enum in Rails"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "account_links", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "collection_tasks", "collections"
  add_foreign_key "collection_tasks", "tasks"
  add_foreign_key "collection_user_favorites", "collections"
  add_foreign_key "collection_user_favorites", "users"
  add_foreign_key "comments", "tasks"
  add_foreign_key "comments", "users"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "group_tasks", "groups"
  add_foreign_key "group_tasks", "tasks"
  add_foreign_key "model_solutions", "tasks"
  add_foreign_key "ratings", "tasks"
  add_foreign_key "ratings", "users"
  add_foreign_key "reports", "tasks"
  add_foreign_key "reports", "users"
  add_foreign_key "task_labels", "tasks"
  add_foreign_key "tasks", "licenses"
  add_foreign_key "tests", "tasks"
  add_foreign_key "tests", "testing_frameworks"
  add_foreign_key "user_identities", "users"
end
