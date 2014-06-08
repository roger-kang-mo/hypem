angular.module('hypem').service 'hypemService', ['$http', ($http) ->
  # $resource('/get_tracks.json', { query: '@query', page: '@page', seed: '@seed' }, {'query': { method: 'GET', isArray: false}})
  fetch: (query, seed, page = 0) ->
    $http.get('/get_tracks.json', { params: { query: query, page: page, seed: seed }})
]

angular.module('hypem').service 'hypemUserService', ['$http', ($http) ->
  fetch: () ->
    $http.get('/get_users.json')
]

