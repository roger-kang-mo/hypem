json.array! @playlist do |track|
  json.partial! 'hypem_track', hypem_track: track
end