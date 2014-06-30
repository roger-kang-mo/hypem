json.tracks do |j|
  j.array! @tracks do |track|
    json.partial! 'track', track: track
  end
end

json.fake_name @fake_name
json.finished @finished
