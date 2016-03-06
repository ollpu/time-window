
twoDigit = (num) ->
  if num > 9
    return "" + num
  else
    return "0" + num

seconds_string = (num) ->
  t = [0,0,0]
  t[2] = parseInt(num)
  t[1] = Math.floor(t[2]/60)
  t[2] = t[2]%60
  t[0] = Math.floor(t[1]/60)
  t[1] = t[1]%60
  twoDigit(t[0]) + ":" + twoDigit(t[1]) + ":" + twoDigit(t[2])

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
    # Initiate playback pause
    if me.hasClass('play')
      me.html('play_circle_filled')
    else
      me.html('pause_circle_filled')
  

# Turbolinks
$(document).on('turbolinks:load', load)
