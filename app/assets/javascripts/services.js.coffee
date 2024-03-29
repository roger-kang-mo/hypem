angular.module('hypem').service 'hypemService', ['$http', ($http) ->
  fetch: (query, seed, page = 0, forceCheck = false) ->
    $http.get('/get_tracks.json', { params: { query: query, page: page, seed: seed, force_check: forceCheck }})
]

angular.module('hypem').service 'hypemUserService', ['$http', ($http) ->
  fetch: () ->
    $http.get('/hypem_users.json')
]

angular.module('hypem').service 'hypemPlaylistService', ['$http', ($http) ->
  fetch: () ->
    $http.get('/hypem_playlists.json')

  create: (data) ->
    $http.post('/hypem_playlists.json', { playlist: data })

  show: (id, seed, page = 0) ->
    $http.get("/hypem_playlists/#{id}.json", { params: { seed: seed, page: page }})
]

angular.module('hypem').service 'hypemTrackService', ['$http', ($http) ->
  addToPlaylist: (id, options) ->
    $http.post("/hypem_tracks/#{id}/add_to_playlist", options)
]

