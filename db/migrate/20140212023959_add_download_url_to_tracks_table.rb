class AddDownloadUrlToTracksTable < ActiveRecord::Migration
  def change
    add_column :hypem_tracks, :download_url, :text
  end
end
