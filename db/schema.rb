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

ActiveRecord::Schema.define(:version => 20131220121052) do

  create_table "disabilities", :force => true do |t|
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "disabilities_question_pairings", :id => false, :force => true do |t|
    t.integer "disability_id"
    t.integer "question_pairing_id"
  end

  add_index "disabilities_question_pairings", ["disability_id"], :name => "index_disabilities_question_pairings_on_disability_id"
  add_index "disabilities_question_pairings", ["question_pairing_id"], :name => "index_disabilities_question_pairings_on_question_pairing_id"

  create_table "disability_translations", :force => true do |t|
    t.integer  "disability_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "disability_translations", ["disability_id"], :name => "index_disability_translations_on_disability_id"
  add_index "disability_translations", ["locale"], :name => "index_disability_translations_on_locale"
  add_index "disability_translations", ["name"], :name => "index_disability_translations_on_name"

  create_table "place_evaluation_answers", :force => true do |t|
    t.integer  "old_place_id"
    t.integer  "old_user_id"
    t.integer  "question_pairing_id"
    t.integer  "answer",              :default => 0
    t.string   "evidence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "place_evaluation_id"
  end

  add_index "place_evaluation_answers", ["place_evaluation_id"], :name => "index_place_evaluation_answers_on_place_evaluation_id"
  add_index "place_evaluation_answers", ["question_pairing_id"], :name => "index_place_evaluation_answers_on_question_pairing_id"

  create_table "place_evaluations", :force => true do |t|
    t.integer  "place_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "disability_id"
  end

  add_index "place_evaluations", ["created_at"], :name => "index_place_evaluations_on_created_at"
  add_index "place_evaluations", ["disability_id"], :name => "index_place_evaluations_on_disability_id"
  add_index "place_evaluations", ["place_id"], :name => "index_place_evaluations_on_place_id"
  add_index "place_evaluations", ["user_id"], :name => "index_place_evaluations_on_user_id"

  create_table "place_translations", :force => true do |t|
    t.integer  "place_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
  end

  add_index "place_translations", ["locale"], :name => "index_place_translations_on_locale"
  add_index "place_translations", ["place_id"], :name => "index_place_translations_on_place_id"

  create_table "places", :force => true do |t|
    t.integer  "venue_id"
    t.integer  "district_id"
    t.decimal  "lat",         :precision => 15, :scale => 12
    t.decimal  "lon",         :precision => 15, :scale => 12
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "places", ["district_id"], :name => "index_places_on_district_id"
  add_index "places", ["venue_id"], :name => "index_places_on_venue_id"

  create_table "question_categories", :force => true do |t|
    t.boolean  "is_common",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order", :default => 99
    t.string   "ancestry"
  end

  add_index "question_categories", ["ancestry"], :name => "index_question_categories_on_ancestry"
  add_index "question_categories", ["is_common"], :name => "index_question_categories_on_is_common"
  add_index "question_categories", ["sort_order"], :name => "index_question_categories_on_sort_order"

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
    t.integer  "sort_order",           :default => 99
  end

  add_index "question_pairings", ["question_category_id", "question_id"], :name => "idx_pairings_ids"
  add_index "question_pairings", ["sort_order"], :name => "index_question_pairings_on_sort_order"

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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                                  :default => "", :null => false
    t.string   "encrypted_password",                                     :default => "", :null => false
    t.integer  "role",                                                   :default => 0,  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "nickname"
    t.string   "avatar"
    t.decimal  "lat",                    :precision => 15, :scale => 12
    t.decimal  "lon",                    :precision => 15, :scale => 12
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "venue_categories", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order", :default => 99
  end

  add_index "venue_categories", ["sort_order"], :name => "index_venue_categories_on_sort_order"

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
    t.integer  "sort_order",           :default => 99
  end

  add_index "venues", ["question_category_id"], :name => "index_venues_on_question_category_id"
  add_index "venues", ["sort_order"], :name => "index_venues_on_sort_order"
  add_index "venues", ["venue_category_id"], :name => "index_venues_on_venue_category_id"

end
