namespace :hypem do
  # require "#{Rails.root}/app/helpers/hypem_helper"

  desc "Update favorites list for each user"

  task :update_user_favorites => :environment do
    include HypemHelper

    HypemUser.find_each do |user|
      get_songs_for_user(user.username)
    end
  end
end