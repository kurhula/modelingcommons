# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100621152433) do

# Could not dump table "appid" because of following StandardError
#   Unknown type 'uuid' for column 'ApplicationID'

# Could not dump table "application" because of following StandardError
#   Unknown type 'uuid' for column 'ID'

# Could not dump table "binaryattachment" because of following StandardError
#   Unknown type 'uuid' for column 'ID'

# Could not dump table "datatype" because of following StandardError
#   Unknown type 'uuid' for column 'ID'

  create_table "email_recommendations", :force => true do |t|
    t.integer  "person_id"
    t.string   "recipient_email_address"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_recommendations", ["node_id"], :name => "index_email_recommendations_on_node_id"
  add_index "email_recommendations", ["person_id"], :name => "index_email_recommendations_on_person_id"

# Could not dump table "execution" because of following StandardError
#   Unknown type 'uuid' for column 'ID'

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logged_actions", :force => true do |t|
    t.integer  "person_id"
    t.datetime "logged_at"
    t.text     "message"
    t.string   "ip_address"
    t.text     "browser_info"
    t.text     "url"
    t.text     "params",       :null => false
    t.text     "session"
    t.text     "cookies"
    t.text     "flash"
    t.text     "referrer"
    t.integer  "node_id"
    t.text     "controller"
    t.text     "action"
  end

  add_index "logged_actions", ["ip_address"], :name => "index_logged_actions_on_ip_address"
  add_index "logged_actions", ["node_id"], :name => "index_logged_actions_on_node_id"
  add_index "logged_actions", ["person_id"], :name => "index_logged_actions_on_person_id"
  add_index "logged_actions", ["referrer"], :name => "index_logged_actions_on_referrer"
  add_index "logged_actions", ["url"], :name => "index_logged_actions_on_url"

  create_table "memberships", :force => true do |t|
    t.integer  "person_id"
    t.integer  "group_id"
    t.boolean  "is_administrator", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "status",           :default => "pending", :null => false
  end

  add_index "memberships", ["group_id"], :name => "index_memberships_on_group_id"
  add_index "memberships", ["person_id", "group_id"], :name => "index_memberships_on_person_id_and_group_id", :unique => true
  add_index "memberships", ["person_id"], :name => "index_memberships_on_person_id"

  create_table "news_items", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news_items", ["created_at"], :name => "index_news_items_on_created_at"
  add_index "news_items", ["person_id"], :name => "index_news_items_on_person_id"
  add_index "news_items", ["title"], :name => "index_news_items_on_title"

  create_table "node_projects", :force => true do |t|
    t.integer  "project_id"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "node_projects", ["node_id"], :name => "index_node_projects_on_node_id"
  add_index "node_projects", ["project_id"], :name => "index_node_projects_on_project_id"

  create_table "nodes", :force => true do |t|
    t.integer  "parent_id"
    t.text     "name",                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "visibility_id",    :default => 1, :null => false
    t.integer  "changeability_id", :default => 1, :null => false
    t.integer  "group_id"
  end

  add_index "nodes", ["changeability_id"], :name => "index_nodes_on_changeability_id"
  add_index "nodes", ["created_at"], :name => "index_nodes_on_created_at"
  add_index "nodes", ["group_id"], :name => "index_nodes_on_group_id"
  add_index "nodes", ["name"], :name => "index_nodes_on_name"
  add_index "nodes", ["parent_id"], :name => "index_nodes_on_parent_id"
  add_index "nodes", ["visibility_id"], :name => "index_nodes_on_visibility_id"

  create_table "people", :force => true do |t|
    t.string   "email_address"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password"
    t.boolean  "administrator"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "people", ["email_address"], :name => "index_people_on_email_address"
  add_index "people", ["first_name"], :name => "index_people_on_first_name"
  add_index "people", ["last_name"], :name => "index_people_on_last_name"

  create_table "permission_settings", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_form"
  end

  add_index "permission_settings", ["name"], :name => "index_permission_settings_on_name"

  create_table "pg_ts_cfg", :id => false, :force => true do |t|
    t.text "ts_name",  :null => false
    t.text "prs_name", :null => false
    t.text "locale"
  end

  create_table "pg_ts_cfgmap", :id => false, :force => true do |t|
    t.text   "ts_name",                  :null => false
    t.text   "tok_alias",                :null => false
    t.string "dict_name", :limit => nil
  end

# Could not dump table "pg_ts_dict" because of following StandardError
#   Unknown type 'name' for column 'dictname'

# Could not dump table "pg_ts_parser" because of following StandardError
#   Unknown type 'name' for column 'prsname'

  create_table "postings", :force => true do |t|
    t.integer  "person_id"
    t.integer  "node_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.boolean  "is_question", :default => false, :null => false
    t.datetime "deleted_at"
    t.datetime "answered_at"
  end

  add_index "postings", ["body"], :name => "index_postings_on_body"
  add_index "postings", ["created_at"], :name => "index_postings_on_created_at"
  add_index "postings", ["node_id"], :name => "index_postings_on_nlmodel_id"
  add_index "postings", ["parent_id"], :name => "index_postings_on_parent_id"
  add_index "postings", ["person_id"], :name => "index_postings_on_person_id"
  add_index "postings", ["title"], :name => "index_postings_on_title"
  add_index "postings", ["updated_at"], :name => "index_postings_on_updated_at"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommendations", :force => true do |t|
    t.integer  "node_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recommendations", ["node_id"], :name => "index_recommendations_on_node_id"
  add_index "recommendations", ["person_id"], :name => "index_recommendations_on_person_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "spam_warnings", :force => true do |t|
    t.integer  "person_id"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spam_warnings", ["node_id"], :name => "index_spam_warnings_on_node_id"
  add_index "spam_warnings", ["person_id"], :name => "index_spam_warnings_on_person_id"

  create_table "tagged_nodes", :force => true do |t|
    t.integer  "node_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id"
    t.text     "comment"
  end

  add_index "tagged_nodes", ["created_at"], :name => "index_tagged_nodes_on_created_at"
  add_index "tagged_nodes", ["node_id"], :name => "index_tagged_nodes_on_node_id"
  add_index "tagged_nodes", ["person_id"], :name => "index_tagged_nodes_on_person_id"
  add_index "tagged_nodes", ["tag_id"], :name => "index_tagged_nodes_on_tag_id"
  add_index "tagged_nodes", ["updated_at"], :name => "index_tagged_nodes_on_updated_at"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["created_at"], :name => "index_tags_on_created_at"
  add_index "tags", ["name"], :name => "index_tags_on_name"
  add_index "tags", ["person_id"], :name => "index_tags_on_person_id"
  add_index "tags", ["updated_at"], :name => "index_tags_on_updated_at"

  create_table "test_tsquery", :id => false, :force => true do |t|
    t.text "txtkeyword"
    t.text "txtsample"
  end

end
