class CreateHypemPlaylistTable < ActiveRecord::Migration
  def up
    create_table :hypem_playlists do |t|
      t.text :name
      t.timestamp :created_at
    end

    create_table :hypem_playlists_hypem_tracks do |t|
      t.integer :hypem_playlist_id
      t.integer :hypem_track_id
    end
  end

  def down
    drop_table :hypem_playlists
    drop_table :hypem_playlists_hypem_tracks
  end
end
