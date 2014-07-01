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

ActiveRecord::Schema.define(:version => 20140701104018) do

  create_table "convention_categories", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "right_to_accessibility", :default => false
  end

  add_index "convention_categories", ["right_to_accessibility"], :name => "index_convention_categories_on_right_to_accessibility"

  create_table "convention_category_translations", :force => true do |t|
    t.integer  "convention_category_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "convention_category_translations", ["convention_category_id"], :name => "index_6b70d14184f63d2943e2c22673e57a76e5a3122b"
  add_index "convention_category_translations", ["locale"], :name => "index_convention_category_translations_on_locale"
  add_index "convention_category_translations", ["name"], :name => "index_convention_category_translations_on_name"

  create_table "disabilities", :force => true do |t|
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active_public",                 :default => true
    t.boolean  "active_certified",              :default => true
    t.integer  "sort_order",       :limit => 1, :default => 1
  end

  add_index "disabilities", ["active_certified"], :name => "index_disabilities_on_active_certified"
  add_index "disabilities", ["active_public"], :name => "index_disabilities_on_active_public"
  add_index "disabilities", ["sort_order"], :name => "index_disabilities_on_sort_order"

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

  create_table "district_translations", :force => true do |t|
    t.integer  "district_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "district_translations", ["district_id"], :name => "index_district_translations_on_district_id"
  add_index "district_translations", ["locale"], :name => "index_district_translations_on_locale"

  create_table "districts", :force => true do |t|
    t.text     "json",       :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "in_tbilisi",                       :default => false
  end

  add_index "districts", ["in_tbilisi"], :name => "index_districts_on_in_tbilisi"

  create_table "page_translations", :force => true do |t|
    t.integer  "page_id"
    t.string   "locale"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_translations", ["locale"], :name => "index_page_translations_on_locale"
  add_index "page_translations", ["page_id"], :name => "index_page_translations_on_page_id"

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["name"], :name => "index_pages_on_name"

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
    t.boolean  "is_certified",  :default => false
  end

  add_index "place_evaluations", ["created_at"], :name => "index_place_evaluations_on_created_at"
  add_index "place_evaluations", ["disability_id"], :name => "index_place_evaluations_on_disability_id"
  add_index "place_evaluations", ["is_certified"], :name => "index_place_evaluations_on_is_certified"
  add_index "place_evaluations", ["place_id"], :name => "index_place_evaluations_on_place_id"
  add_index "place_evaluations", ["user_id"], :name => "index_place_evaluations_on_user_id"

  create_table "place_images", :force => true do |t|
    t.integer  "place_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "user_id"
    t.datetime "taken_at"
  end

  add_index "place_images", ["place_id"], :name => "index_place_images_on_place_id"
  add_index "place_images", ["taken_at"], :name => "index_place_images_on_taken_at"
  add_index "place_images", ["user_id"], :name => "index_place_images_on_user_id"

  create_table "place_summaries", :force => true do |t|
    t.integer  "place_id"
    t.integer  "summary_type"
    t.integer  "summary_type_identifier"
    t.integer  "data_type"
    t.integer  "data_type_identifier"
    t.integer  "disability_id"
    t.decimal  "score",                   :precision => 10, :scale => 6
    t.integer  "special_flag"
    t.integer  "num_answers"
    t.integer  "num_evaluations"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_certified",                                           :default => false
    t.integer  "venue_id"
    t.integer  "venue_category_id"
    t.decimal  "percentage",              :precision => 5,  :scale => 2
    t.integer  "num_yes"
    t.integer  "num_no"
  end

  add_index "place_summaries", ["data_type", "data_type_identifier"], :name => "idx_place_summary_data_type"
  add_index "place_summaries", ["disability_id"], :name => "index_place_summaries_on_disability_id"
  add_index "place_summaries", ["is_certified"], :name => "index_place_summaries_on_is_certified"
  add_index "place_summaries", ["place_id"], :name => "index_place_summaries_on_place_id"
  add_index "place_summaries", ["summary_type", "summary_type_identifier"], :name => "idx_place_summary_summary_type"
  add_index "place_summaries", ["venue_category_id"], :name => "index_place_summaries_on_venue_category_id"
  add_index "place_summaries", ["venue_id"], :name => "index_place_summaries_on_venue_id"

  create_table "place_translations", :force => true do |t|
    t.integer  "place_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.string   "search_name"
    t.string   "search_address"
  end

  add_index "place_translations", ["locale"], :name => "index_place_translations_on_locale"
  add_index "place_translations", ["place_id"], :name => "index_place_translations_on_place_id"
  add_index "place_translations", ["search_address"], :name => "index_place_translations_on_search_address"
  add_index "place_translations", ["search_name"], :name => "index_place_translations_on_search_name"

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
    t.boolean  "is_common",                  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order",                 :default => 99
    t.string   "ancestry"
    t.integer  "category_type", :limit => 1, :default => 1
  end

  add_index "question_categories", ["ancestry"], :name => "index_question_categories_on_ancestry"
  add_index "question_categories", ["category_type"], :name => "index_question_categories_on_category_type"
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

  create_table "question_pairing_convention_categories", :force => true do |t|
    t.integer  "question_pairing_id"
    t.integer  "convention_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_pairing_convention_categories", ["convention_category_id"], :name => "idx_qpcc_cc_id"
  add_index "question_pairing_convention_categories", ["question_pairing_id"], :name => "idx_qpcc_qp_id"

  create_table "question_pairing_translations", :force => true do |t|
    t.integer  "question_pairing_id"
    t.string   "locale"
    t.string   "evidence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reference"
    t.text     "help_text"
  end

  add_index "question_pairing_translations", ["locale"], :name => "index_question_pairing_translations_on_locale"
  add_index "question_pairing_translations", ["question_pairing_id"], :name => "index_6a79dfceebefcdc2e82ab7c645f57a5add2e7696"

  create_table "question_pairings", :force => true do |t|
    t.integer  "question_category_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order",                    :default => 99
    t.boolean  "is_exists",                     :default => false
    t.boolean  "required_for_accessibility",    :default => false
    t.boolean  "is_domestic_legal_requirement", :default => false
  end

  add_index "question_pairings", ["is_domestic_legal_requirement"], :name => "index_question_pairings_on_is_domestic_legal_requirement"
  add_index "question_pairings", ["question_category_id", "question_id"], :name => "idx_pairings_ids"
  add_index "question_pairings", ["required_for_accessibility"], :name => "index_question_pairings_on_required_for_accessibility"
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

  create_table "right_translations", :force => true do |t|
    t.integer  "right_id"
    t.string   "locale"
    t.string   "name"
    t.string   "convention_article"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "right_translations", ["locale"], :name => "index_right_translations_on_locale"
  add_index "right_translations", ["name"], :name => "index_right_translations_on_name"
  add_index "right_translations", ["right_id"], :name => "index_right_translations_on_right_id"

  create_table "rights", :force => true do |t|
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
    t.integer  "district_id"
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

  create_table "venue_question_categories", :force => true do |t|
    t.integer  "venue_id"
    t.integer  "question_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "venue_question_categories", ["question_category_id"], :name => "index_venue_question_categories_on_question_category_id"
  add_index "venue_question_categories", ["venue_id"], :name => "index_venue_question_categories_on_venue_id"

  create_table "venue_rights", :force => true do |t|
    t.integer  "venue_id"
    t.integer  "right_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "venue_rights", ["right_id"], :name => "index_venue_rights_on_right_id"
  add_index "venue_rights", ["venue_id"], :name => "index_venue_rights_on_venue_id"

  create_table "venue_summaries", :force => true do |t|
    t.integer  "venue_id"
    t.integer  "venue_category_id"
    t.integer  "summary_type"
    t.integer  "summary_type_identifier"
    t.integer  "data_type"
    t.integer  "data_type_identifier"
    t.integer  "disability_id"
    t.decimal  "score",                   :precision => 10, :scale => 6
    t.integer  "special_flag"
    t.integer  "num_answers"
    t.integer  "num_evaluations"
    t.integer  "num_places"
    t.boolean  "is_certified"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "accessibility_type"
  end

  add_index "venue_summaries", ["accessibility_type"], :name => "index_venue_summaries_on_accessibility_type"
  add_index "venue_summaries", ["data_type", "data_type_identifier"], :name => "idx_venue_summary_data_type"
  add_index "venue_summaries", ["disability_id"], :name => "index_venue_summaries_on_disability_id"
  add_index "venue_summaries", ["is_certified"], :name => "index_venue_summaries_on_is_certified"
  add_index "venue_summaries", ["summary_type", "summary_type_identifier"], :name => "idx_venue_summary_summary_type"
  add_index "venue_summaries", ["venue_category_id"], :name => "index_venue_summaries_on_venue_category_id"
  add_index "venue_summaries", ["venue_id"], :name => "index_venue_summaries_on_venue_id"

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
    t.integer  "custom_question_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order",                         :default => 99
    t.integer  "custom_public_question_category_id"
  end

  add_index "venues", ["custom_public_question_category_id"], :name => "index_venues_on_custom_public_question_category_id"
  add_index "venues", ["custom_question_category_id"], :name => "index_venues_on_custom_question_category_id"
  add_index "venues", ["sort_order"], :name => "index_venues_on_sort_order"
  add_index "venues", ["venue_category_id"], :name => "index_venues_on_venue_category_id"

end
