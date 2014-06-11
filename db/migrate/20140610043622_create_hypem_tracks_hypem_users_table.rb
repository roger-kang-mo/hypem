class CreateHypemTracksHypemUsersTable < ActiveRecord::Migration
  def change
    create_table :hypem_tracks_hypem_users do |t|
      t.integer :hypem_track_id
      t.integer :hypem_user_id
    end
  end
end
