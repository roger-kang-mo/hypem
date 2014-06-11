class HypemTrack < ActiveRecord::Base
  attr_accessible :artist, :song, :post_url, :url, :download_url, :track_found

  has_and_belongs_to_many :hypem_users
  has_and_belongs_to_many :hypem_playlist
end