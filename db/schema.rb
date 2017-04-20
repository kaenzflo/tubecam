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

ActiveRecord::Schema.define(version: 20170419155247) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "media", force: :cascade do |t|
    t.string   "path"
    t.string   "filename"
    t.string   "mediatype"
    t.datetime "datetime"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "sequence"
    t.integer  "frame"
    t.integer  "tubecamstation_id"
    t.json     "exifdata"
    t.boolean  "deleted"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["tubecamstation_id"], name: "index_media_on_tubecamstation_id", using: :btree
  end

  create_table "tubecamstations", force: :cascade do |t|
    t.string   "serialnumber"
    t.boolean  "status"
    t.integer  "user_id"
    t.text     "description"
    t.boolean  "active"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_tubecamstations_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "e_mail"
    t.string   "username"
    t.string   "firstname"
    t.string   "lastname"
    t.integer  "role_id"
    t.boolean  "trusted"
    t.boolean  "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "media", "tubecamstations"
  add_foreign_key "tubecamstations", "users"
end
