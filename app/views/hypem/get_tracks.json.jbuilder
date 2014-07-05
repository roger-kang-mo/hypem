json.tracks do |j|
  j.array! @track_data[:tracks] do |track|
    json.partial! 'track', track: track
  end
end

json.fake_name @track_data[:fake_name]
json.finished @track_data[:finished]
