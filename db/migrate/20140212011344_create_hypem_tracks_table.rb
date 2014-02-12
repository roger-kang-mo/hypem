class CreateHypemTracksTable < ActiveRecord::Migration
  def change
    create_table :hypem_tracks do |t|
      t.text :url
      t.text :artist
      t.text :song
      t.text :post_url
    end
  end
end
