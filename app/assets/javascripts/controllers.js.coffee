angular.module('hypem').controller 'HypemController', ['$scope', '$rootScope', 'hypemService', 'hypemUserService', 'hypemPlaylistService', 'hypemTrackService', '$sce', '$modal', ($scope, $rootScope, hypemService, hypemUserService, hypemPlaylistService, hypemTrackService, $sce, $modal) ->
  $scope.init = (seed) ->
    $scope.trackLists = { hypemmain: { tracks: [], fakeName: 'Library', page: 0, finished: false, playing: false, type: 'library' }}
    $scope.loadingList = ''
    $scope.currentList = "hypemmain"
    $scope.queryText = ''
    $scope.currentTracks = [{src: "http://api.soundcloud.com/tracks/134249577/stream?consumer_key=nH8p0jYOkoVEZgJukRlG6w", type: "audio/mp3"}]
    $scope.currentPlaylist = { name: 'pizza', tracks: [] }
    $scope.seed = seed
    $scope.options = { forceCheck: false, playlistName: '' }
    $scope.queries = {}
    $scope.lastListLoaded = ''
    $scope.showAddPlaylistInput = false
    # $scope.selectedPlaylist = ''

    $scope.currentTrackUrl = $sce.trustAsResourceUrl("http://api.soundcloud.com/tracks/134249577/stream?consumer_key=nH8p0jYOkoVEZgJukRlG6w")

    $scope.query('hypemmain')

    getUsers()
    getPlaylists()

    _.defer ->
      $scope.audioPlayer.on 'play', () -> $scope.updateCurrentlyPlaying()

  getUsers = () ->
    hypemUserService.fetch().then (response) ->
      users = response.data

      for user in users
        $scope.trackLists[user.username] = { tracks: [], fakeName: user.fake_name, fetched: false,  page: 0, type: "user", id: user.id}

  getPlaylists = () ->
    hypemPlaylistService.fetch().then (response) ->
      playlists = response.data

      for playlist in playlists
        $scope.trackLists[playlist.name] = { tracks: [], fakeName: playlist.name, fetched: false,  page: 0, type: "playlist", id: playlist.id}

  allowQuery = (query) ->
    $scope.queries[query] ||= 0
    queriedNum = $scope.queries[query]
    if (!$scope.options.forceCheck && queriedNum >= 2) || (!$scope.options.forceCheck && $scope.trackLists[query].finished)
      showForceCheckModal()
      return false
    else
      $scope.queries[query] = if queriedNum then queriedNum + 1 else 1
      return true

  showForceCheckModal = () ->
    options = {
      templateUrl: 'force_check_modal.html'
      size: 'lg'
      scope: $scope
    }

    $scope.currentModal = $modal.open(options)

  $scope.showOptions = () ->
    $scope.closeModal()

    options = {
      templateUrl: 'options_modal.html'
      size: 'lg'
      scope: $scope
    }

    $scope.currentModal = $modal.open(options)

  $scope.closeModal = () ->
    if $scope.currentModal
      try
        $scope.currentModal.dismiss()
      catch err

      $scope.currentModal = null

  $scope.playNextOrPrevious = (type) ->
    if type == "previous"
      if $scope.audioPlayer.currentTrack > 1
        $scope.audioPlayer.pause()
        $scope.audioPlayer.prev(true)
        $scope.updateCurrentlyPlaying()
      else
        $scope.audioPlayer.play($scope.audioPlayer.$playlist.length - 1, false)
    else
      if $scope.audioPlayer.currentTrack != $scope.audioPlayer.$playlist.length
        $scope.audioPlayer.pause()
        $scope.audioPlayer.next(true)
        $scope.updateCurrentlyPlaying()
      else
        $scope.audioPlayer.play(0, false)


  setupTrackObjects = (tracks) ->
    trackObjects = []
    for track in tracks
      obj = {src: track.download_url, trackData: track, type: "audio/mp3"}
      trackObjects.push obj

    trackObjects

  $scope.enterQuery = (query) ->
    $scope.setList(query, 'user', 0) if allowQuery(query)

  $scope.updateCurrentlyPlaying = () ->
    # audioPlayer, Y U ZERO BASED INDEX AND ONE BASED INDEX?!
    $scope.currentlyPlaying = $scope.currentPlaylist.tracks[$scope.audioPlayer.currentTrack - 1]


  $scope.setTrackUrl = (track) ->
    if $scope.lastListLoaded != $scope.currentList || $scope.currentPlaylist.name != $scope.currentList
      $scope.currentPlaylist.name = $scope.currentList
      $scope.currentPlaylist.tracks = $scope.currentTracks
      $scope.audioPlayer.load($scope.currentPlaylist.tracks, false)
      $scope.lastListLoaded = $scope.currentList

    index = 0
    for listTrack, i in $scope.currentPlaylist.tracks
      index = i if track.download_url == listTrack.trackData.download_url

    $scope.audioPlayer.pause()
    $scope.audioPlayer.play(index, false)
    $scope.currentlyPlaying = $scope.currentPlaylist.tracks[index]

  setupList = (listName) ->
    $scope.currentList = listName
    $scope.currentTracks = $scope.trackLists[listName]['tracks']
    $scope.lastListLoaded = listName

    playlistLength = $scope.currentPlaylist.tracks.length
    if (playlistLength && !$scope.currentPlaylist.tracks[0].src) || !playlistLength
      $scope.currentPlaylist.name = $scope.currentList
      $scope.currentPlaylist.tracks = $scope.currentTracks

  $scope.setList = (listName, obj, page = 0) ->
    unless $scope.loadingList
      listObj = $scope.trackLists[listName]
      if listObj && (listObj.tracks.length > 0 || listObj.fetched)
        setupList(listName)
      else
        if obj.type == 'playlist'
          queryPlaylist(obj)
        else
          $scope.query(listName, page)


  queryPlaylist = (playlist, page = 0) ->
    $scope.loadingList = playlist.fakeName
    # page = parseInt($scope.trackLists[$scope.currentList].page)
    # $scope.trackLists[$scope.currentList].page = page += 1
    hypemPlaylistService.show(playlist.id, $scope.seed, page).then (response) =>
      tracks = setupTrackObjects(response.data)
      name = playlist.fakeName
      if name
        if tracks.length > 0
          $scope.trackLists[name].tracks = tracks
        else
          $scope.trackLists[name].fullyLoaded = true
        $scope.trackLists[name].fetched = true
        $scope.loadingList = ''

        $scope.setList(name, $scope.trackLists[name])

  $scope.query = (listName, page = 0) ->
    $scope.loadingList = listName
    hypemService.fetch(listName, $scope.seed, page, $scope.options.forceCheck).then (data) =>
      listName = listName

      if $scope.trackLists[listName] && $scope.trackLists[listName]['tracks'].length >= 0
        tracks = setupTrackObjects(data.data.tracks)

        if tracks.length > 0
          $scope.trackLists[listName]['tracks'] =  $scope.trackLists[listName]['tracks'].concat tracks
        else
          #herbie
          $scope.trackLists[listName].fullyLoaded = true

        $scope.trackLists[listName]['fakeName'] = data.data.fake_name if data.data.fake_name && data.data.fake_name != listName
        $scope.trackLists[listName]['fetched'] = true
        $scope.trackLists[listName]['finished'] = data.data.finished
      else
        $scope.trackLists[listName] = {}
        $scope.trackLists[listName]['tracks'] = setupTrackObjects(data.data.tracks)
        $scope.trackLists[listName]['fetched'] = true
        $scope.trackLists[listName]['showUsername'] = true
        $scope.trackLists[listName]['fakeName'] = data.data.fake_name
        $scope.trackLists[listName]['finished'] = data.data.finished

      setupList(listName)
      $scope.loadingList = ''

  $scope.addToPlaylist = (track, selectedPlaylist) ->
    hypemTrackService.addToPlaylist(track.trackData.id, { playlist_id: selectedPlaylist.id }).then (response) =>
      selectedPlaylist.finished = false

  $scope.paginateMe = () ->
    currentList = $scope.trackLists[$scope.currentList]

    unless currentList.fullyLoaded || $scope.loadingList
      currentPage = parseInt(currentList.page)
      $scope.trackLists[$scope.currentList].page = currentPage += 1

    #So I can use legacy endpoint for now
    if currentList.type == 'playlist' && currentList.fakeName != "Library"
      queryPlaylist(currentList, currentPage)
    else
      $scope.query($scope.currentList, currentPage)

  $scope.seekPercentage = ($event) ->
    percentage = ($event.offsetX / $event.target.offsetWidth)
    if percentage <= 1
      percentage
    else
      0

  $scope.setVolume = (newVolume) ->
    $scope.audioPlayer.setVolume(newVolume) if newVolume > 0 && newVolume <= 1

  $scope.toggleAddPlaylist = () ->
    $scope.showAddPlaylistInput = !$scope.showAddPlaylistInput

  $scope.createPlaylist = (playlistName) ->
    hypemPlaylistService.create({ name: playlistName }).then (response) ->
      name = response.data.name
      $scope.trackLists[name] = response.data
      $scope.trackLists[name].fakeName = name
      $scope.trackLists[name].type = 'playlist'
      $scope.trackLists[name].tracks = []
      $scope.toggleAddPlaylist()
      $scope.options.playlistName = ''


]
