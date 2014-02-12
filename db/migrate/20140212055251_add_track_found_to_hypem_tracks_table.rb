class AddTrackFoundToHypemTracksTable < ActiveRecord::Migration
  def change
    add_column :hypem_tracks, :track_found, :boolean
  end
end
