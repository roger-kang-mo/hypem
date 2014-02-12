$ ->
  $(document).on 'click', '.disabled', (e) ->
    e.stopPropagation()
    e.preventDefault()

  $('#submit-username').click ->
    data = { username: $('#username').val() }
    $.ajax
      url: '/get_tracks'
      data: data
      dataType: 'json'
      success: (data) ->
        console.log data
        listData(data)
      error: (response, data) ->
        console.log response
        console.log data

  listData = (data) ->
    dataList = $('#data-list')

    for k, v of data
      artistAndSong = "#{v.artist} - #{v.song}"

      if v.track_found
        downloadLink = "<a target='_blank' href=#{v.download_url}>Download</a>"
      else
        downloadLink = "<a href='' class='disabled' disabled='disabled'>Unavailable</a>"

      dataList.append("<li> #{artistAndSong}: #{downloadLink}</li>")