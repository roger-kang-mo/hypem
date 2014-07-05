angular.module('hypem').filter 'onlyPlaylists', () ->
  (lists, scope) ->
    filtered = []
    for k, v of lists
      filtered.push v unless v['type'] == 'user' || v['fakeName'] == 'Library' || scope.currentList == v['fakeName']

    filtered
angular.module('hypem').filter 'filterByType', () ->
  (lists, type) ->
    filtered = {}

    for k, v of lists
      filtered[k] = v if v['type'] == type

    filtered
