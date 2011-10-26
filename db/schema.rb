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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111026181324) do

  create_table "certificates", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "certificate_id"
    t.integer  "key_id"
    t.integer  "parent_certificate_owner_id"
    t.text     "body"
    t.integer  "request_status"
    t.string   "common_name"
    t.string   "organization"
    t.string   "organization_unit"
    t.string   "country"
    t.integer  "days"
    t.string   "locality"
    t.string   "email"
    t.string   "state"
    t.string   "sha"
    t.integer  "serial"
    t.boolean  "ca"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keys", :force => true do |t|
    t.string   "title"
    t.string   "password_digest"
    t.text     "body"
    t.text     "public_body"
    t.integer  "user_id"
    t.string   "sha"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.integer  "sign_id"
    t.string   "sha"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file"
    t.string   "file_sha"
  end

  create_table "signs", :force => true do |t|
    t.integer  "key_id"
    t.integer  "certificate_id"
    t.text     "body"
    t.string   "sha"
    t.integer  "signable_id"
    t.string   "signable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :null => false
    t.string   "password_digest"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "block",           :default => false
    t.boolean  "admin",           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
