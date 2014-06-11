require 'mechanize'
require "open-uri"

module HypemHelper

  SOURCE_URL = "http://hypem.com/serve/source/"

  ADJECTIVES = [
      "autumn", "hidden", "bitter", "misty", "silent", "empty", "dry", "dark",
      "summer", "icy", "delicate", "quiet", "white", "cool", "spring", "winter",
      "patient", "twilight", "dawn", "crimson", "wispy", "weathered", "blue",
      "billowing", "broken", "cold", "damp", "falling", "frosty", "green",
      "long", "late", "lingering", "bold", "little", "morning", "muddy", "old",
      "red", "rough", "still", "small", "sparkling", "throbbing", "shy",
      "wandering", "withered", "wild", "black", "young", "holy", "solitary",
      "fragrant", "aged", "snowy", "proud", "floral", "restless", "divine",
      "polished", "ancient", "purple", "lively", "nameless", "arcane"
    ]

  NOUNS = [
    "waterfall", "river", "breeze", "moon", "rain", "wind", "sea", "morning",
    "snow", "lake", "sunset", "pine", "shadow", "leaf", "dawn", "glitter",
    "forest", "hill", "cloud", "meadow", "sun", "glade", "bird", "brook",
    "butterfly", "bush", "dew", "dust", "field", "fire", "flower", "firefly",
    "feather", "grass", "haze", "mountain", "night", "pond", "darkness",
    "snowflake", "silence", "sound", "sky", "shape", "surf", "thunder",
    "violet", "water", "wildflower", "wave", "water", "resonance", "sun",
    "wood", "dream", "cherry", "tree", "fog", "frost", "voice", "paper",
    "frog", "smoke", "star", "savannah", "wilderness", "tree-stump"
  ]

  def get_random_name
    random_name = "#{ADJECTIVES.sample}-#{NOUNS.sample}"
    while HypemUser.where(fake_name: random_name).count > 0 do
      random_name = "#{ADJECTIVES.sample}-#{NOUNS.sample}"
    end

    random_name
  end

  def get_songs_for_user(user)
    return_data = {}
    @user = user
    @username = user.username
    @mechanize = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }

    pages = [""]

    # /tags/#{genre} for genre pages
    dest_url = "http://hypem.com/#{@username}?ax=1"
    track_list = []

    begin
      pages.concat get_pages()

      track_list = pages.map { |p| get_songs_for_page("http://hypem.com/#{@username}#{p}?ax=1") }

      return_data = track_list.flatten
    rescue Exception => e
      logger.error e
      return_data[:error] = "Couldn't retrieve songs. User may not exist."
    end

    return_data
  end

  def get_songs_for_page(url)
    track_list = []

    begin
      @mechanize.get(url) do |page|
        tracks = JSON.parse(page.search("#displayList-data").first)['tracks']

        track_list = tracks.map do |track|
          url = "#{SOURCE_URL}#{track['id']}/#{track['key']}"

          track_data = {
            artist: track['artist'],
            song: track['song'],
            post_url: track['posturl'],
            url: url
          }

          hypem_track = HypemTrack.where(artist: track_data[:artist], song: track_data[:song]).first

          if hypem_track
            track_data[:download_url] = hypem_track.download_url
            track_data[:track_found] = hypem_track.track_found
          else
            track_data = get_download_url(track_data)
          end

          track_data
        end

        track_list
      end
    rescue Mechanize::ResponseCodeError => e
      logger.error e
    end

    track_list
  end

  def get_download_url(track_data)

    download_url = ""

    begin
      @mechanize.get(track_data[:url]) do |page|
        download_url = JSON.parse(page.body)['url']

        track_data[:download_url] = download_url
        track_data[:track_found] = true
      end
    rescue Exception => e
      p "Couldn't get download url for #{track_data[:artist]} - #{track_data[:song]}."
      track_data[:download_url] = ""
      track_data[:track_found] = false
    end

    new_track = HypemTrack.create(track_data)
    new_track.save

    @user.hypem_tracks << new_track

    track_data
  end

  def get_pages()
    pages = []
    current_page = 2

    begin
      @mechanize.get("http://hypem.com/#{@username}?ax=1") do |page|
        page_objects = page.search(".paginator").children.to_a

        page_objects.select! do |p|
          p.name == 'a' && !p.children.first.text.include?("See more")
        end

        page_objects.count.times do |t|
          pages << "/#{current_page}"
          current_page += 1
        end
      end
    rescue Mechanize::ResponseCodeError => e
      logger.error e
    end

    pages
  end
end