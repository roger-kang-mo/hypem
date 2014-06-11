class HypemUser < ActiveRecord::Base
  attr_accessible :username, :fake_name


  validates :username, presence: true 
  has_and_belongs_to_many :hypem_tracks
end