# --- Time-string helper functions ---
twoDigit = (num) ->
  if num > 9
    return "" + num
  else
    return "0" + num

seconds_string = (num) ->
  t = [0,0,0]
  t[2] = parseInt(num)
  t[1] = t[2] // 60
  t[2] = t[2]  % 60
  t[0] = t[1] // 60
  t[1] = t[1]  % 60
  twoDigit(t[0]) + ":" + twoDigit(t[1]) + ":" + twoDigit(t[2])
# ------------

# --- Host-object. Contains all global values for the cue player ---
@host =
  play: off
  ticker_start: new Date().getTime()
  ticker_remaining: 0
  ticker_elapsed: 0
  ticker_over: 0
  current_cue: $()
  live_indicator: $()
# ------------

# --- Refresh/restore time displays in cues and the master clock view ---
restore_t = (part_t) ->
  seconds = part_t.data('seconds-original')
  part_t.html(seconds_string(seconds))
  seconds

restore = (part) ->
  restore_t part.find('.part-time')
  
refresh_indicator = ->
  t_string = seconds_string(host.ticker_remaining)
  host.live_indicator.html(t_string)
  t_string
# ------------

# --- Cleanly set host.play variable. Updates the play/pause button ---
set_play = (play, ppbutton = $('#live-started .controls .pp')) ->
  host.play = play
  if play
    ppbutton.addClass('play')
    ppbutton.html('pause_circle_filled')
  else
    ppbutton.removeClass('play')
    ppbutton.html('play_circle_filled')
# ------------

# --- Go-To functions. Jump to next/prev/custom cue ---
go_to = (part, refresh = true) ->
  host.current_cue.attr('id', '')
  restore host.current_cue # Restore previous cue
  host.current_cue = part
  host.ticker_remaining = restore part # Restore part, and set ticker_remaining
  host.ticker_over = 0
  part.attr('id', 'counting')
  refresh_indicator() if refresh
  
go_to_next = (refresh = true) ->
  next = host.current_cue.next()
  if next.length
    go_to next, refresh
  else
    set_play off

go_to_prev = (refresh = true) ->
  prev = host.current_cue.prev()
  if prev.length
    go_to prev, refresh
  else
    go_to host.current_cue, refresh
# ------------

# --- Ticker functions (advances the clock every second) ---
schedule_tick = (tick_f) ->
  actual = (new Date().getTime()) - host.ticker_start
  # Next tick in 1 second +/- correction of any accumulated error
  setTimeout tick_f, 1000 - (actual - host.ticker_elapsed)

tick = -> # Process tick
  if host.play
    host.ticker_elapsed += 1000
    host.ticker_remaining-- if host.ticker_remaining # Ensure that it's not made negative
    t_string = refresh_indicator()
    host.current_cue.find('.part-time').html(t_string)
    if host.ticker_remaining <= 0
      go_to_next(false) until host.ticker_remaining > 0 or !host.play
      refresh_indicator()
    schedule_tick tick

start_ticker = ->
  set_play on
  host.ticker_start = new Date().getTime()
  # Resuming from pause: Decrease the time to the next step by how much was
  # timed over before pausing (i.e. Paused @ 10.765 -> wait for 765ms less)
  host.ticker_elapsed = -host.ticker_over
  host.ticker_over = 0
  schedule_tick(tick)

pause_ticker = ->
  set_play off
  actual = (new Date().getTime()) - host.ticker_start
  host.ticker_over = actual - host.ticker_elapsed
# ------------

# --- Load. Executed when the page is loaded (via Tubolinks or otherwise) ---
# Defines all hooks for controls and cue buttons, and initializes the logic
load = ->
  $('#start-live-show').click ->
    # Enter live mode
    $('#live-view').addClass('live')
  
  # Playback controls
  controls = $('#live-view .controls')
  controls.find('.pp').click (e) ->
    e.preventDefault()
    set_play(!host.play, $(this)) # Toggle play state
    if host.play
      start_ticker()
    else
      pause_ticker()
    
  controls.find('.fr').click (e) ->
    e.preventDefault()
    go_to_prev()
  
  controls.find('.ff').click (e) ->
    e.preventDefault()
    go_to_next()
  
  controls.find('.restart').click (e) ->
    e.preventDefault()
    go_to $('#live-list .live-part').first()
  
  host.live_indicator = $('#live-indicator')
  
  # Cue display
  
  # Set initial data-seconds' and contents to time displays
  $('#live-list .part-time').each -> restore_t $(this)
  
  parts = $('#live-list .live-part')
  parts.dblclick ->
    # Jump to this cue
    if host.current_cue != $(this)
      go_to $(this)
      
  
  go_to parts.first() # Start from first part
  refresh_indicator()

# Turbolinks
$(document).on('turbolinks:load', load)
# ------------
