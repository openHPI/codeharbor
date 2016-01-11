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

ActiveRecord::Schema.define(version: 20160111183437) do

  create_table "account_links", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "push_url"
    t.string   "account_name"
    t.integer  "user_id"
  end

  add_index "account_links", ["user_id"], name: "index_account_links_on_user_id"

  create_table "answers", force: :cascade do |t|
    t.integer  "comment_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "text"
  end

  add_index "answers", ["comment_id"], name: "index_answers_on_comment_id"
  add_index "answers", ["user_id"], name: "index_answers_on_user_id"

  create_table "assemblies_parts", id: false, force: :cascade do |t|
    t.integer "assembly_id"
    t.integer "part_id"
  end

  add_index "assemblies_parts", ["assembly_id"], name: "index_assemblies_parts_on_assembly_id"
  add_index "assemblies_parts", ["part_id"], name: "index_assemblies_parts_on_part_id"

  create_table "comments", force: :cascade do |t|
    t.text     "text"
    t.integer  "exercise_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "comments", ["exercise_id"], name: "index_comments_on_exercise_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "exercise_files", force: :cascade do |t|
    t.boolean  "main"
    t.text     "content"
    t.string   "path"
    t.boolean  "solution"
    t.string   "filetype"
    t.integer  "exercise_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "exercise_files", ["exercise_id"], name: "index_exercise_files_on_exercise_id"

  create_table "exercises", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "maxrating"
    t.boolean  "public"
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
  end

  add_index "labels", ["label_category_id"], name: "index_labels_on_label_category_id"

  create_table "ratings", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "exercise_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "ratings", ["exercise_id"], name: "index_ratings_on_exercise_id"
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id"

  create_table "testing_frameworks", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tests", force: :cascade do |t|
    t.text     "content"
    t.integer  "rating"
    t.string   "feedback_message"
    t.integer  "testing_framework_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "exercise_id"
  end

  add_index "tests", ["exercise_id"], name: "index_tests_on_exercise_id"
  add_index "tests", ["testing_framework_id"], name: "index_tests_on_testing_framework_id"

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
