
twoDigit = (num) ->
  if num > 9
    return "" + num
  else
    return "0" + num

seconds_string = (num) ->
  t = [0,0,0]
  t[2] = parseInt(num)
  t[1] = t[2] // 60
  t[2] = t[2]%60
  t[0] = t[1] // 60
  t[1] = t[1]%60
  twoDigit(t[0]) + ":" + twoDigit(t[1]) + ":" + twoDigit(t[2])
  
@host =
  play: false
  ticker_start: new Date().getTime()
  ticker_elapsed: 0
  ticker_freeze_time: new Date().getTime()

load = ->
  $('#start-live-show').click ->
    # Enter live mode
    $('#live-view').addClass('live')
  
  # Playback controls
  controls = $('#live-view .controls')
  controls.find('.pause').click (e) ->
    e.preventDefault()
    me = $(this)
    me.toggleClass('play')
    host.play = !host.play
    if host.play
      me.html('pause_circle_filled')
    else
      me.html('play_circle_filled')
    # TODO: Send pause/play signal to clients
  
  # Cue display
  $('#live-list .part-time').each ->
    me = $(this)
    seconds = me.data('seconds-original')
    me.data('seconds', seconds)
    me.html(seconds_string(seconds))
  $('#live-list .live-part').dblclick ->
    # Jump to this cue
    if $('#counting') != $(this)
      $('#counting').attr('id', '')
      $(this).attr('id', 'counting')
      # TODO: do stuff
  .first().attr('id', 'counting')

# Turbolinks
$(document).on('turbolinks:load', load)
