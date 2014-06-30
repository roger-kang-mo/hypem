angular.module('hypem').filter 'onlyPlaylists', () ->
  (lists) ->
    filtered = []
    for k, v of lists 
      filtered.push v unless v['type'] == 'user'

    filtered