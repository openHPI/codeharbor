# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_13_152530) do

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
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "cart_exercises", id: :serial, force: :cascade do |t|
    t.integer "exercise_id"
    t.integer "cart_id"
    t.index ["cart_id"], name: "index_cart_exercises_on_cart_id"
    t.index ["exercise_id"], name: "index_cart_exercises_on_exercise_id"
  end

  create_table "carts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "collection_exercises", id: :serial, force: :cascade do |t|
    t.integer "exercise_id"
    t.integer "collection_id"
    t.index ["collection_id"], name: "index_collection_exercises_on_collection_id"
    t.index ["exercise_id"], name: "index_collection_exercises_on_exercise_id"
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
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "text"
    t.integer "exercise_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_comments_on_exercise_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "descriptions", id: :serial, force: :cascade do |t|
    t.string "text"
    t.integer "exercise_id"
    t.string "language", default: "EN"
    t.boolean "primary"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id"], name: "index_descriptions_on_exercise_id"
  end

  create_table "execution_environments", id: :serial, force: :cascade do |t|
    t.string "language"
    t.string "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exercise_authors", id: :serial, force: :cascade do |t|
    t.integer "exercise_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_exercise_authors_on_exercise_id"
    t.index ["user_id"], name: "index_exercise_authors_on_user_id"
  end

  create_table "exercise_files", id: :serial, force: :cascade do |t|
    t.text "content"
    t.string "path"
    t.boolean "solution"
    t.integer "exercise_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visibility"
    t.string "name"
    t.string "purpose"
    t.string "role"
    t.boolean "hidden"
    t.boolean "read_only"
    t.integer "file_type_id"
    t.bigint "test_id"
    t.index ["exercise_id"], name: "index_exercise_files_on_exercise_id"
    t.index ["file_type_id"], name: "index_exercise_files_on_file_type_id"
    t.index ["test_id"], name: "index_exercise_files_on_test_id"
  end

  create_table "exercise_labels", force: :cascade do |t|
    t.integer "exercise_id"
    t.integer "label_id"
    t.index ["exercise_id"], name: "index_exercise_labels_on_exercise_id"
    t.index ["label_id"], name: "index_exercise_labels_on_label_id"
  end

  create_table "exercise_relations", id: :serial, force: :cascade do |t|
    t.integer "origin_id"
    t.integer "clone_id"
    t.integer "relation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exercises", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "instruction"
    t.integer "maxrating"
    t.boolean "private"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "execution_environment_id"
    t.integer "downloads", default: 0
    t.integer "license_id"
    t.boolean "deleted"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "predecessor_id"
    t.index ["execution_environment_id"], name: "index_exercises_on_execution_environment_id"
    t.index ["license_id"], name: "index_exercises_on_license_id"
    t.index ["predecessor_id"], name: "index_exercises_on_predecessor_id"
    t.index ["user_id"], name: "index_exercises_on_user_id"
    t.index ["uuid"], name: "index_exercises_on_uuid", unique: true
  end

  create_table "file_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_extension"
    t.string "editor_mode"
  end

  create_table "group_memberships", id: :serial, force: :cascade do |t|
    t.integer "member_id", null: false
    t.string "member_type", null: false
    t.integer "group_id"
    t.string "group_type"
    t.string "group_name"
    t.string "membership_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_name"], name: "index_group_memberships_on_group_name"
    t.index ["group_type", "group_id"], name: "index_group_memberships_on_group_type_and_group_id"
    t.index ["member_type", "member_id"], name: "index_group_memberships_on_member_type_and_member_id"
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
    t.string "text"
    t.integer "sender_id"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "param_type"
    t.integer "param_id"
    t.string "sender_status", default: "s"
    t.string "recipient_status", default: "u"
  end

  create_table "ratings", id: :serial, force: :cascade do |t|
    t.integer "rating"
    t.integer "exercise_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_ratings_on_exercise_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "relations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.integer "exercise_id"
    t.integer "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_reports_on_exercise_id"
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

  create_table "testing_frameworks", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "version"
  end

  create_table "tests", id: :serial, force: :cascade do |t|
    t.string "feedback_message"
    t.integer "testing_framework_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "exercise_id"
    t.float "score"
    t.index ["exercise_id"], name: "index_tests_on_exercise_id"
    t.index ["testing_framework_id"], name: "index_tests_on_testing_framework_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.boolean "deleted"
    t.string "username"
    t.text "description"
    t.boolean "email_confirmed", default: false
    t.string "confirm_token"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
  end

  add_foreign_key "account_links", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "carts", "users"
  add_foreign_key "comments", "exercises"
  add_foreign_key "comments", "users"
  add_foreign_key "descriptions", "exercises"
  add_foreign_key "exercise_authors", "exercises"
  add_foreign_key "exercise_authors", "users"
  add_foreign_key "exercise_files", "exercises"
  add_foreign_key "exercise_files", "file_types"
  add_foreign_key "exercises", "execution_environments"
  add_foreign_key "exercises", "licenses"
  add_foreign_key "exercises", "users"
  add_foreign_key "ratings", "exercises"
  add_foreign_key "ratings", "users"
  add_foreign_key "reports", "exercises"
  add_foreign_key "reports", "users"
  add_foreign_key "tests", "exercises"
  add_foreign_key "tests", "testing_frameworks"
end
