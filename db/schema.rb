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

ActiveRecord::Schema.define(version: 20151230200622) do

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
  end

  add_index "tests", ["testing_framework_id"], name: "index_tests_on_testing_framework_id"

end
