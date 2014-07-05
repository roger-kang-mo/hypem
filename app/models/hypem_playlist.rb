class HypemPlaylist < ActiveRecord::Base
  attr_accessible :name

  validates :name, uniqueness: true, presence: true
  validate :uniqueness_with_fake_name

  has_and_belongs_to_many :hypem_track

  def uniqueness_with_fake_name
    if name == 'Library' || HypemUser.where(fake_name: name).length > 0
      errors.add(:name, "This name is taken or reserved")
    end
  end
end