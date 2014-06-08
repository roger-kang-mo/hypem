class HypemUser < ActiveRecord::Base
  attr_accessible :username, :fake_name


  validates :username, presence: true 
  has_many :hypem_tracks
end