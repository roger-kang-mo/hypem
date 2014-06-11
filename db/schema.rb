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

ActiveRecord::Schema.define(:version => 20140610044134) do

  create_table "hypem_playlists", :force => true do |t|
    t.text     "name"
    t.datetime "created_at"
  end

  create_table "hypem_playlists_hypem_tracks", :force => true do |t|
    t.integer "hypem_playlist_id"
    t.integer "hypem_track_id"
  end

  create_table "hypem_tracks", :force => true do |t|
    t.text    "url"
    t.text    "artist"
    t.text    "song"
    t.text    "post_url"
    t.text    "download_url"
    t.boolean "track_found"
  end

  create_table "hypem_tracks_hypem_users", :force => true do |t|
    t.integer "hypem_track_id"
    t.integer "hypem_user_id"
  end

  create_table "hypem_users", :force => true do |t|
    t.text    "username"
    t.string  "fake_name"
    t.integer "last_checked"
  end

end
