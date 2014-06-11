angular.module('hypem').controller 'HypemController', ['$scope', '$rootScope', 'hypemService', 'hypemUserService', '$sce', '$modal', ($scope, $rootScope, hypemService, hypemUserService, $sce, $modal) ->
  $scope.init = (seed) ->
    $scope.trackLists = { hypemmain: { tracks: [], fakeName: 'Library' }}
    $scope.loadingList = ''
    $scope.currentList = "hypemmain"
    $scope.queryText = ''
    $scope.libraryPage = 0
    $scope.seed = seed
    $scope.forceCheck = false
    $scope.queries = {}
    $scope.currentQuery = ''
    $scope.currentTrackUrl = $sce.trustAsResourceUrl("http://api.soundcloud.com/tracks/134249577/stream?consumer_key=nH8p0jYOkoVEZgJukRlG6w")

    $scope.query('hypemmain')

    getUsers()

    # audiojs.events.ready ->
      # $scope.audioObject = audiojs.createAll(
        # ->
        # ->
      # )[0]
      # $scope.audioPlayer = angular.element('#audio-player')
      # volume = $scope.audioObject
      # volume.setVolume(0.5)

  getUsers = () ->
    hypemUserService.fetch().then (data) ->
      users = data.data

      for user in users
        $scope.trackLists[user.username] = { tracks: [], fakeName: user.fake_name, fetched: false}

  setupList = (listName) ->
    $scope.currentList = listName
    $scope.currentTracks = $scope.trackLists[listName]['tracks']

  allowQuery = (query) ->
    queriedNum = $scope.queries[query]
    if queriedNum >= 2
      showForceCheckModal()
      return false
    else
      $scope.queries[query] = if queriedNum then queriedNum + 1 else 1
      return true

  showForceCheckModal = () ->
    options = {
      templateUrl: 'force_check_modal.html'
      size: 'sm'
    }

    $modal.open(options)

  $scope.setTrackUrl = (track) ->
    console.log(track)
    # $scope.currentTrackUrl = $sce.trustAsResourceUrl(track.download_url)
    # $scope.currentTrackUrl = "pozza"
    # $scope.audioPlayer.load()
    # $scope.audioObject.play()

  $scope.setList = (listName) ->
    unless $scope.loadingList
      if $scope.trackLists[listName] && $scope.trackLists[listName]['tracks'].length > 0
        setupList(listName)
      else
        $scope.query(listName)

  $scope.query = (listName, page = 0) ->

    if allowQuery(listName) || $scope.forceCheck
      $scope.libraryPage = page if listName == "hypemmain"
      $scope.loadingList = listName
      $scope.currentQuery = listName
      hypemService.fetch(listName, $scope.seed, page, $scope.forceCheck).then (data) ->
        listName = $scope.currentQuery
        if $scope.trackLists[listName] && $scope.trackLists[listName]['tracks'].length >= 0
          $scope.trackLists[listName]['tracks'] =  $scope.trackLists[listName]['tracks'].concat data.data.tracks
          $scope.trackLists[listName]['fakeName'] = data.data.fake_name if data.data.fake_name && data.data.fake_name != listName
          $scope.trackLists[listName]['fetched'] = true
        else
          $scope.trackLists[listName] = {}
          $scope.trackLists[listName]['tracks'] = data.data.tracks
          $scope.trackLists[listName]['fetched'] = true
          $scope.trackLists[listName]['showUsername'] = true
          $scope.trackLists[listName]['fakeName'] = data.data.fake_name
        setupList(listName)
        $scope.loadingList = ''

  $scope.addToPlaylist = (track) ->
    console.log track
]
