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

ActiveRecord::Schema.define do

  create_table "banned_url_patterns", :force => true do |t|
    t.string "pattern"
  end

  create_table "commands", :force => true do |t|
    t.string   "name"
    t.text     "url"
    t.text     "description"
    t.integer  "uses",            :limit => 11, :default => 0
    t.boolean  "spam",                          :default => false
    t.datetime "last_use_date"
    t.datetime "golden_egg_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
