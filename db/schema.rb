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

ActiveRecord::Schema.define(:version => 20131129082420) do

  create_table "question_categories", :force => true do |t|
    t.boolean  "is_common",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_categories", ["is_common"], :name => "index_question_categories_on_is_common"

  create_table "question_category_translations", :force => true do |t|
    t.integer  "question_category_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_category_translations", ["locale"], :name => "index_question_category_translations_on_locale"
  add_index "question_category_translations", ["question_category_id"], :name => "index_015e56867c95ef35f93185af6897d91e5e0c6800"

  create_table "question_pairing_translations", :force => true do |t|
    t.integer  "question_pairing_id"
    t.string   "locale"
    t.string   "evidence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_pairing_translations", ["locale"], :name => "index_question_pairing_translations_on_locale"
  add_index "question_pairing_translations", ["question_pairing_id"], :name => "index_6a79dfceebefcdc2e82ab7c645f57a5add2e7696"

  create_table "question_pairings", :force => true do |t|
    t.integer  "question_category_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_pairings", ["question_category_id", "question_id"], :name => "idx_pairings_ids"

  create_table "question_translations", :force => true do |t|
    t.integer  "question_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_translations", ["locale"], :name => "index_question_translations_on_locale"
  add_index "question_translations", ["question_id"], :name => "index_question_translations_on_question_id"

  create_table "questions", :force => true do |t|
    t.integer  "question_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["question_category_id"], :name => "index_questions_on_question_category_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.integer  "role",                   :default => 0,  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "venue_categories", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venue_category_translations", :force => true do |t|
    t.integer  "venue_category_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "venue_category_translations", ["locale"], :name => "index_venue_category_translations_on_locale"
  add_index "venue_category_translations", ["venue_category_id"], :name => "index_ebb6287e836f963636058fbf5e5bfbd51e8bdebe"

  create_table "venue_translations", :force => true do |t|
    t.integer  "venue_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "venue_translations", ["locale"], :name => "index_venue_translations_on_locale"
  add_index "venue_translations", ["venue_id"], :name => "index_venue_translations_on_venue_id"

  create_table "venues", :force => true do |t|
    t.integer  "venue_category_id"
    t.integer  "question_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "venues", ["question_category_id"], :name => "index_venues_on_question_category_id"
  add_index "venues", ["venue_category_id"], :name => "index_venues_on_venue_category_id"

end
