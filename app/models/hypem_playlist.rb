class HypemPlaylist < ActiveRecord::Base
  attr_accessible :name, :created_at

  has_and_belongs_to_many :hypem_track
end