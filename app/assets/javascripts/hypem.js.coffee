$ ->
  window.hypem = {}

  hypem.main = (args) ->
    pageWrapper = $('#page-wrapper')
    userNameField = $('#username')
    userName = userNameField.val()
    usersDropdown = $('#user-dropdown')
    messageDisplay = $('#message-display')
    currentLibraryPage = 0

    $(document).on 'click', '.disabled', (e) ->
      e.stopPropagation()
      e.preventDefault()

    $(document).on 'click', '.user-select', (e) ->
      selectedName = e.target.text
      openUsernamePage(selectedName)

    $('#get-library').click ->
      if $('#library-page').length > 0
        hideAllPages()
        $('#library-page').show()
      else
        queryLibrary(0)

    $(document).on 'click', '.show-more', ->
      currentLibraryPage += 1
      queryLibrary(currentLibraryPage)

    $('#submit-username').click ->
      userName = userNameField.val()

      if hasPage(userName)
        openUsernamePage(userName)
      else
        data = { username: userName }
        $.ajax
          url: '/get_tracks'
          data: data
          dataType: 'json'
          success: (data) ->
            console.log data
            listData(data)
            updateDropdown()
          error: (data) ->
            showError(JSON.parse(data.responseText).error)

    queryLibrary = (page) ->
      data = { page: page}
      $.ajax
        url: '/get_library'
        data: data
        dataType: 'json'
        success: (data) ->
          console.log data
          listData(data, true)
        error: (data) ->
          console.log data
          showError(JSON.parse(data.responseText).error)

    showError = (error) ->
      messageDisplay.text(error)

    clearError = ->
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
              <th>Song</th>
              <th>Artist</th>
              <th>Download Link</th>
          """

      pageHtml = tableHtml unless isPaginated

      for k, v of data

        if v.track_found
          downloadLink = "<a target='_blank' href=#{v.download_url} alt='download'><span class='glyphicon glyphicon-download'/> Download</a>"
        else
          downloadLink = "<a href='' class='disabled' disabled='disabled'><span class='glyphicon glyphicon-ban-circle'/> Unavailable</a>"

        pageHtml += "<tr><td>#{v.song}</td><td>#{v.artist}</td><td>#{downloadLink}</td></tr>"

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

      else
        hideAllPages()
        pageWrapper.append(pageHtml)

    hideAllPages = ->
      $('.page').hide()

    updateDropdown = () ->
      newElement = "<li><a href='#' class='user-select'>#{userName}</a></li>"
      usersDropdown.append(newElement)


