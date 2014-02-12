class HypemTrack < ActiveRecord::Base
  attr_accessible :artist, :song, :post_url, :url, :download_url, :track_found
end