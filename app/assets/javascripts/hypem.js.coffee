$ ->
  window.hypem = {}

  hypem.main = (args) ->
    pageWrapper = $('#page-wrapper')
    userNameField = $('#username')
    userName = userNameField.val()
    usersDropdown = $('#user-dropdown')
    messageDisplay = $('#message-display')
    loaderIcon = $('.loader-img')
    showMoreButton = null
    currentLibraryPage = 1
    audioPlayer = $('#audio-player')
    currentlyPlaying = ""
    as = null
    requestedPermission = false

    notifications = window.webkitNotifications || window.mozNotifications || window.Notifications;

    playingClass = "bg-success"

    $ ->
      audiojs.events.ready ->
        as = audiojs.createAll(
          trackEnded: ->
            playNext()
          loadError: ->
            playNext()
            showMessage("There was an error loading that track. Skipping.", true)
        )
        audioPlayer = $('#audio-player')
        volume = as[0]
        volume.setVolume(0.5)

        window.hypem.as = as

      if args.tracks
        listData(args.tracks, true)

    $(document).keypress (e) ->
      if e.which == 732 && e.altKey && e.shiftKey
        playNext()
        e.preventDefault()
      else if e.which == 8719 && e.altKey && e.shiftKey
        pausePlay()
        e.preventDefault()


    $(document).on 'click', '.disabled', (e) ->
      e.stopPropagation()
      e.preventDefault()

    $(document).on 'click', '.user-select', (e) ->
      selectedName = e.target.text
      openUsernamePage(selectedName)

    $('#get-library').click ->
      hideAllPages()
      $('#library-page').show()

    $(document).on 'click', '.listen', (e) ->
      if notifications
        if !requestedPermission && notifications.checkPermission() == 1
          notifications.requestPermission()
        requestPermission = true
      targetElem = $(e.target)
      playSong(targetElem)

    $(document).on 'click', '.show-more', ->
      currentLibraryPage += 1
      queryLibrary(currentLibraryPage)

    $("#query-form").submit (e) ->
      e.stopPropagation()
      e.preventDefault()
      userName = userNameField.val()
      queryUsername(userName)

    pausePlay = () ->
      audiojs.instances.audiojs0.playPause()

    playNext = () ->
      foundTrack = false
      nextTrack = null
      current = $('.bg-success')
      if current
        nextElement = current.next()
        while(nextElement.length > 0 && foundTrack == false)
          foundTrack = nextElement.find('.disabled').length == 0
          nextElement = nextElement.next() unless foundTrack && nextElement.find('play-song').is(':checked')
        
        if foundTrack
          playSong(nextElement.find('.listen'))
        else
          clearMessage()

    playSong = (elem) ->
      rowElem = elem.parents('.track-row') 
      sourceUrl = elem.data('source')
      audioPlayer.attr('src', sourceUrl)
      audioPlayer.load()
      as[0].play()

      removePlaying()
      markPlaying(rowElem)

      getSong(elem.parents('.track-row'))
      showMessage(currentlyPlaying)

      notify()  if hypem.isHidden() && notifications

    notify = () ->
      if notifications && notifications.checkPermission() == 0
        notifications.createNotification('/favicon.ico', "Now Playing", currentlyPlaying).show()

    getSong = (rowElem) ->
      song = rowElem.find('.song').text()
      artist = rowElem.find('.artist').text()
      currentlyPlaying = "Playing #{artist} - #{song}"

    markPlaying = (elem) ->
      elem.addClass(playingClass)

    removePlaying = () ->
      $(".#{playingClass}").removeClass(playingClass)

    preloadSongs = () ->


    queryUsername = (username) ->
      showLoader()
      if hasPage(username)
        openUsernamePage(username)
      else
        data = { username: username }
        $.ajax
          url: '/get_tracks'
          data: data
          dataType: 'json'
          success: (data) ->
            listData(data)
            updateDropdown()
          error: (data) ->
            showMessage(JSON.parse(data.responseText).error, as[0].playing)
          complete: ->
            hideLoader()

    queryLibrary = (page) ->
      showLoader()
      data = { page: page}
      $.ajax
        url: '/get_library'
        data: data
        dataType: 'json'
        success: (data) ->
          if data.length > 0
            listData(data, true)
          else
            disableShowMoreButton()
        error: (data) ->
          showMessage(JSON.parse(data.responseText).error, as[0].playing)
        complete: ->
          hideLoader()

    enableShowMoreButton = () ->
      showMoreButton.removeClass('disabled')

    disableShowMoreButton = () ->
      showMoreButton.addClass('disabled')

    showLoader = () ->
      loaderIcon.show()

    hideLoader = () ->
      loaderIcon.hide()

    showMessage = (message, returnToSong) ->
      messageDisplay.text(message)
      if returnToSong
        setTimeout (->
          showMessage currentlyPlaying
          return
        ), 3000

    clearMessage = ->
      messageDisplay.text('')

    hasPage = (name) ->
      $("##{name}").length > 0

    openUsernamePage = (name) ->
      desiredPage = $("##{name}")
      unless desiredPage.is(':visible')
        hideAllPages()
        desiredPage.show()

    listData = (data, isPaginated) ->
      pageHtml = ""
      userName = 'library-page' if isPaginated

      tableHtml = """
          <div class='page' id='#{userName}'>
            <table class='data-wrapper table'>
              <th>Play?</th>
              <th>Song</th>
              <th>Artist</th>
              <th>Play</th>
              <th>Download</th>
          """

      pageHtml = tableHtml unless isPaginated

      for k, v of data

        song = v.song
        artist = v.artist
        downloadTitle = "#{artist} - #{song}"

        if v.track_found
          listenLink = "<a class='listen' data-source='#{v.download_url}'><span class='glyphicon glyphicon-headphones'/> Listen</a>"
          downloadLink = "<a target='_blank' href=#{v.download_url} alt='download' download='#{downloadTitle}'><span class='glyphicon glyphicon-download'/> Download</a>"
        else
          listenLink = "<a href='' class='disabled' disabled='disabled'><span class='glyphicon glyphicon-ban-circle'/> Unavailable</a>"
          downloadLink = "<a href='' class='disabled' disabled='disabled'><span class='glyphicon glyphicon-ban-circle'/> Unavailable</a>"


        pageHtml += "<tr class='track-row'><td><input class='play-song' type='checkbox' checked></td><td class='song'>#{song}</td><td class='artist'>#{artist}</td><td>#{listenLink}</td><td>#{downloadLink}</td></tr>"

      pageHtml += "</table></div>" unless isPaginated

      if isPaginated
        table = $('#library-page table')

        if table.length > 0
          table.append(pageHtml)
        else
          hideAllPages()
          pageHtml = tableHtml + pageHtml + "</table>"
          pageHtml += "<div><button class='btn btn-default show-more'><span class='glyphicon glyphicon-music'></span> Show More</button></div></div>"
          pageWrapper.append(pageHtml)
          showMoreButton = $('.show-more')

      else
        hideAllPages()
        pageWrapper.append(pageHtml)

    hideAllPages = ->
      $('.page').hide()

    updateDropdown = () ->
      newElement = "<li><a href='#' class='user-select'>#{userName}</a></li>"
      usersDropdown.append(newElement)


