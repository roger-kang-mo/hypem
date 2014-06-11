angular.module('hypem').service 'hypemService', ['$http', ($http) ->
  # $resource('/get_tracks.json', { query: '@query', page: '@page', seed: '@seed' }, {'query': { method: 'GET', isArray: false}})
  fetch: (query, seed, page = 0, forceCheck = false) ->
    $http.get('/get_tracks.json', { params: { query: query, page: page, seed: seed, force_check: forceCheck }})
]

angular.module('hypem').service 'hypemUserService', ['$http', ($http) ->
  fetch: () ->
    $http.get('/get_users.json')
]

