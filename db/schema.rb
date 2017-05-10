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

ActiveRecord::Schema.define(version: 20170422144129) do

  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'users', force: :cascade do |t|
    t.string   'username'
    t.string   'firstname'
    t.string   'lastname'
    t.string   'password'
    t.boolean  'spotter_role',           default: false
    t.boolean  'verified_spotter_role',  default: false
    t.boolean  'trapper_role',           default: false
    t.boolean  'admin_role',             default: false
    t.boolean  'active'
    t.datetime 'created_at',                             null: false
    t.datetime 'updated_at',                             null: false
    t.string   'email',                  default: '',    null: false
    t.string   'encrypted_password',     default: '',    null: false
    t.string   'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer  'sign_in_count',          default: 0,     null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.inet     'current_sign_in_ip'
    t.inet     'last_sign_in_ip'
    t.index ['email'], name: 'index_users_on_email', unique: true, using: :btree
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true, using: :btree
  end

  create_table 'tubecam_devices', force: :cascade do |t|
    t.integer  'user_id',           null: false
    t.string   'serialnumber'
    t.text     'description'
    t.boolean  'active'
    t.datetime 'created_at',        null: false
    t.datetime 'updated_at',        null: false
    t.index ['user_id'], name: 'index_tubecam_devices_on_user_id', using: :btree
  end

  create_table 'sequences', force: :cascade do |t|
    t.integer  'tubecam_device_id',        null: false
    t.integer  'sequence_no'
    t.datetime 'created_at',        null: false
    t.datetime 'updated_at',        null: false
    t.index ['tubecam_device_id'], name: 'index_sequences_on_tubecam_device_id', using: :btree
  end

  create_table 'media', force: :cascade do |t|
    t.integer  'sequence_id',       null: false
    t.string   'original_path'
    t.string   'original_filename'
    t.string   'filename_hash'
    t.string   'mediatype'
    t.datetime 'datetime'
    t.float    'longitude'
    t.float    'latitude'
    t.integer  'frame'
    t.json     'exifdata'
    t.boolean  'deleted'
    t.datetime 'created_at',        null: false
    t.datetime 'updated_at',        null: false
    t.index ['sequence_id'], name: 'index_media_on_sequence_id', using: :btree
  end

  create_table 'annotations_lookup_tables', force: :cascade do |t|
    t.string   'annotation_id'
    t.string   'name'
    t.string   'family'
    t.string   'genus'
    t.string   'species'
    t.boolean  'selectable'
    t.integer  'body_length_min'
    t.integer  'body_length_max'
    t.integer  'tail_length_min'
    t.integer  'tail_length_max'
    t.integer  'hindfoot_length_min'
    t.integer  'hindfoot_length_max'
    t.boolean  'tail_hairy'
    t.boolean  'tail_naked'
    t.boolean  'face_painting'
    t.boolean  'bodyshape_compact'
    t.boolean  'bodyshape_streched'
    t.boolean  'ears_visible'
    t.boolean  'ears_hidden'
    t.boolean  'snout_blunt'
    t.boolean  'snout_pointy'
    t.datetime 'created_at',   null: false
    t.datetime 'updated_at',   null: false
  end

  create_table 'annotations', force: :cascade do |t|
    t.integer  'user_id'
    t.integer  'sequence_id'
    t.integer  'annotations_lookup_table_id'
    t.integer  'verified_id'
    t.datetime 'created_at',   null: false
    t.datetime 'updated_at',   null: false
  end

  add_foreign_key 'tubecam_devices', 'users'
  add_foreign_key 'sequences', 'tubecam_devices'
  add_foreign_key 'media', 'sequences'

  add_foreign_key 'annotations', 'users'
  add_foreign_key 'annotations', 'sequences'
  add_foreign_key 'annotations', 'annotations_lookup_tables'

  add_index :annotations, [:user_id, :sequence_id], unique: true
  add_index :sequences, [:tubecam_device_id, :sequence_no], unique: true

end
