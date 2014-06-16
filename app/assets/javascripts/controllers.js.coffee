angular.module('hypem').controller 'HypemController', ['$scope', '$rootScope', 'hypemService', 'hypemUserService', '$sce', '$modal', ($scope, $rootScope, hypemService, hypemUserService, $sce, $modal) ->
  $scope.init = (seed) ->
    $scope.trackLists = { hypemmain: { tracks: [], fakeName: 'Library', page: 0, finished: false, playing: false }}
    $scope.loadingList = ''
    $scope.currentList = "hypemmain"
    $scope.queryText = ''
    $scope.currentTracks = [{src: "http://api.soundcloud.com/tracks/134249577/stream?consumer_key=nH8p0jYOkoVEZgJukRlG6w", type: "audio/mp3"}]
    $scope.seed = seed
    $scope.options = { forceCheck: false }
    $scope.queries = {}
    $scope.currentQuery = ''
    $scope.lastListLoaded = ''

    $scope.currentTrackUrl = $sce.trustAsResourceUrl("http://api.soundcloud.com/tracks/134249577/stream?consumer_key=nH8p0jYOkoVEZgJukRlG6w")

    $scope.query('hypemmain')

    getUsers()

  getUsers = () ->
    hypemUserService.fetch().then (data) ->
      users = data.data

      for user in users
        $scope.trackLists[user.username] = { tracks: [], fakeName: user.fake_name, fetched: false,  page: 0}

  setupList = (listName) ->
    $scope.currentList = listName
    $scope.currentTracks = $scope.trackLists[listName]['tracks']

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
        trackObj = $scope.audioPlayer.$playlist[$scope.audioPlayer.currentTrack - 1].trackData
        $scope.audioPlayer.pause()
        $scope.audioPlayer.prev(true)
    else
      if $scope.audioPlayer.currentTrack != $scope.audioPlayer.$playlist.length
        $scope.audioPlayer.pause()
        $scope.audioPlayer.next(true)
        trackObj = $scope.audioPlayer.$playlist[$scope.audioPlayer.currentTrack + 1].trackData

  setupTrackObjects = (tracks) ->
    trackObjects = []
    for track in tracks
      obj = {src: track.download_url, trackData: track, type: "audio/mp3"}
      trackObjects.push obj

    trackObjects

  $scope.enterQuery = (query) ->
    $scope.setList(query, 0) if allowQuery(query)

  $scope.setTrackUrl = (track) ->
    if $scope.lastListLoaded != $scope.currentList
      $scope.audioPlayer.load($scope.currentTracks, false)
      $scope.lastListLoaded = $scope.currentList

    index = 0
    for listTrack, i in $scope.currentTracks
      index = i if track.id == listTrack.trackData.id

    $scope.audioPlayer.pause()
    $scope.audioPlayer.play(index, false)

  $scope.setList = (listName, page = 0) ->
    unless $scope.loadingList
      if $scope.trackLists[listName] && $scope.trackLists[listName]['tracks'].length > 0
        setupList(listName)
      else
        $scope.query(listName, page)

  $scope.query = (listName, page = 0) ->
    $scope.loadingList = listName
    $scope.currentQuery = listName
    hypemService.fetch(listName, $scope.seed, page, $scope.options.forceCheck).then (data) ->
      listName = $scope.currentQuery

      if $scope.trackLists[listName] && $scope.trackLists[listName]['tracks'].length >= 0
        $scope.trackLists[listName]['tracks'] =  $scope.trackLists[listName]['tracks'].concat setupTrackObjects(data.data.tracks)
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


  $scope.addToPlaylist = (track) ->
    console.log track

  $scope.paginateMe = () ->
    currentPage = $scope.trackLists[$scope.currentList]['page']
    $scope.trackLists[$scope.currentList]['page'] = currentPage += 1
    $scope.query($scope.currentList, currentPage) unless $scope.loadingList

  $scope.seekPercentage = ($event) ->
    percentage = ($event.offsetX / $event.target.offsetWidth)
    if percentage <= 1
      percentage
    else
      0

  $scope.setVolume = (newVolume) ->
    $scope.audioPlayer.setVolume(newVolume) if newVolume > 0 && newVolume <= 1

]
