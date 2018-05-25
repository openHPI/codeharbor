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

ActiveRecord::Schema.define(version: 20180525134311) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_links", force: :cascade do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "push_url"
    t.string   "account_name"
    t.integer  "user_id"
    t.string   "oauth2_token"
    t.string   "client_id"
    t.string   "client_secret"
    t.index ["user_id"], name: "index_account_links_on_user_id", using: :btree
  end

  create_table "account_links_users", id: false, force: :cascade do |t|
    t.integer "account_link_id", null: false
    t.integer "user_id",         null: false
    t.index ["account_link_id", "user_id"], name: "index_account_links_users_on_account_link_id_and_user_id", using: :btree
  end

  create_table "answers", force: :cascade do |t|
    t.integer  "comment_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "text"
    t.index ["comment_id"], name: "index_answers_on_comment_id", using: :btree
    t.index ["user_id"], name: "index_answers_on_user_id", using: :btree
  end

  create_table "assemblies_parts", id: false, force: :cascade do |t|
    t.integer "assembly_id"
    t.integer "part_id"
    t.index ["assembly_id"], name: "index_assemblies_parts_on_assembly_id", using: :btree
    t.index ["part_id"], name: "index_assemblies_parts_on_part_id", using: :btree
  end

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id", using: :btree
  end

  create_table "carts_exercises", force: :cascade do |t|
    t.integer "exercise_id"
    t.integer "cart_id"
    t.index ["cart_id"], name: "index_carts_exercises_on_cart_id", using: :btree
    t.index ["exercise_id"], name: "index_carts_exercises_on_exercise_id", using: :btree
  end

  create_table "collections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "title"
  end

  create_table "collections_exercises", force: :cascade do |t|
    t.integer "exercise_id"
    t.integer "collection_id"
    t.index ["collection_id"], name: "index_collections_exercises_on_collection_id", using: :btree
    t.index ["exercise_id"], name: "index_collections_exercises_on_exercise_id", using: :btree
  end

  create_table "collections_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "collection_id"
    t.index ["collection_id"], name: "index_collections_users_on_collection_id", using: :btree
    t.index ["user_id"], name: "index_collections_users_on_user_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.text     "text"
    t.integer  "exercise_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["exercise_id"], name: "index_comments_on_exercise_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "descriptions", force: :cascade do |t|
    t.string  "text"
    t.integer "exercise_id"
    t.string  "language",    default: "EN"
    t.index ["exercise_id"], name: "index_descriptions_on_exercise_id", using: :btree
  end

  create_table "execution_environments", force: :cascade do |t|
    t.string   "language"
    t.string   "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exercise_authors", force: :cascade do |t|
    t.integer  "exercise_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["exercise_id"], name: "index_exercise_authors_on_exercise_id", using: :btree
    t.index ["user_id"], name: "index_exercise_authors_on_user_id", using: :btree
  end

  create_table "exercise_files", force: :cascade do |t|
    t.text     "content"
    t.string   "path"
    t.boolean  "solution"
    t.integer  "exercise_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.boolean  "visibility"
    t.string   "name"
    t.string   "purpose"
    t.string   "role"
    t.boolean  "hidden"
    t.boolean  "read_only"
    t.integer  "file_type_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.index ["exercise_id"], name: "index_exercise_files_on_exercise_id", using: :btree
    t.index ["file_type_id"], name: "index_exercise_files_on_file_type_id", using: :btree
  end

  create_table "exercise_group_accesses", force: :cascade do |t|
    t.integer  "exercise_id"
    t.integer  "group_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["exercise_id"], name: "index_exercise_group_accesses_on_exercise_id", using: :btree
    t.index ["group_id"], name: "index_exercise_group_accesses_on_group_id", using: :btree
  end

  create_table "exercise_relations", force: :cascade do |t|
    t.integer  "origin_id"
    t.integer  "clone_id"
    t.integer  "relation_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "exercises", force: :cascade do |t|
    t.string   "title"
    t.string   "instruction"
    t.integer  "maxrating"
    t.boolean  "private"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "user_id"
    t.integer  "execution_environment_id"
    t.integer  "downloads",                default: 0
    t.integer  "license_id"
    t.boolean  "deleted"
    t.index ["execution_environment_id"], name: "index_exercises_on_execution_environment_id", using: :btree
    t.index ["license_id"], name: "index_exercises_on_license_id", using: :btree
    t.index ["user_id"], name: "index_exercises_on_user_id", using: :btree
  end

  create_table "exercises_labels", id: false, force: :cascade do |t|
    t.integer "exercise_id"
    t.integer "label_id"
    t.index ["exercise_id"], name: "index_exercises_labels_on_exercise_id", using: :btree
    t.index ["label_id"], name: "index_exercises_labels_on_label_id", using: :btree
  end

  create_table "file_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "file_extension"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.integer  "member_id",       null: false
    t.string   "member_type",     null: false
    t.integer  "group_id"
    t.string   "group_type"
    t.string   "group_name"
    t.string   "membership_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_name"], name: "index_group_memberships_on_group_name", using: :btree
    t.index ["group_type", "group_id"], name: "index_group_memberships_on_group_type_and_group_id", using: :btree
    t.index ["member_type", "member_id"], name: "index_group_memberships_on_member_type_and_member_id", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "label_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "labels", force: :cascade do |t|
    t.string   "name"
    t.integer  "label_category_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "color"
    t.index ["label_category_id"], name: "index_labels_on_label_category_id", using: :btree
  end

  create_table "licenses", force: :cascade do |t|
    t.string   "name"
    t.string   "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string   "text"
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "param_type"
    t.integer  "param_id"
    t.string   "sender_status",    default: "s"
    t.string   "recipient_status", default: "u"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "exercise_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["exercise_id"], name: "index_ratings_on_exercise_id", using: :btree
    t.index ["user_id"], name: "index_ratings_on_user_id", using: :btree
  end

  create_table "relations", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "exercise_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["exercise_id"], name: "index_reports_on_exercise_id", using: :btree
    t.index ["user_id"], name: "index_reports_on_user_id", using: :btree
  end

  create_table "testing_frameworks", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "version"
  end

  create_table "tests", force: :cascade do |t|
    t.string   "feedback_message"
    t.integer  "testing_framework_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "exercise_id"
    t.integer  "exercise_file_id"
    t.float    "score"
    t.index ["exercise_file_id"], name: "index_tests_on_exercise_file_id", using: :btree
    t.index ["exercise_id"], name: "index_tests_on_exercise_id", using: :btree
    t.index ["testing_framework_id"], name: "index_tests_on_testing_framework_id", using: :btree
  end

  create_table "user_groups", force: :cascade do |t|
    t.boolean  "is_admin",   default: false
    t.boolean  "is_active",  default: false
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["group_id"], name: "index_user_groups_on_group_id", using: :btree
    t.index ["user_id"], name: "index_user_groups_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "role",                   default: "user"
    t.boolean  "deleted"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "username"
    t.text     "description"
    t.boolean  "email_confirmed",        default: false
    t.string   "confirm_token"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
  end

  add_foreign_key "account_links", "users"
  add_foreign_key "answers", "comments"
  add_foreign_key "answers", "users"
  add_foreign_key "carts", "users"
  add_foreign_key "comments", "exercises"
  add_foreign_key "comments", "users"
  add_foreign_key "descriptions", "exercises"
  add_foreign_key "exercise_authors", "exercises"
  add_foreign_key "exercise_authors", "users"
  add_foreign_key "exercise_files", "exercises"
  add_foreign_key "exercise_files", "file_types"
  add_foreign_key "exercise_group_accesses", "exercises"
  add_foreign_key "exercise_group_accesses", "groups"
  add_foreign_key "exercises", "execution_environments"
  add_foreign_key "exercises", "licenses"
  add_foreign_key "exercises", "users"
  add_foreign_key "labels", "label_categories"
  add_foreign_key "ratings", "exercises"
  add_foreign_key "ratings", "users"
  add_foreign_key "reports", "exercises"
  add_foreign_key "reports", "users"
  add_foreign_key "tests", "exercise_files"
  add_foreign_key "tests", "exercises"
  add_foreign_key "tests", "testing_frameworks"
  add_foreign_key "user_groups", "groups", on_delete: :cascade
  add_foreign_key "user_groups", "users"
end
