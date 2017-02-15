# --- Time-string helper functions ---
twoDigit = (num) ->
  if num > 9
    return "" + num
  else
    return "0" + num

t_to_string = (t) ->
  twoDigit(t[0]) + ":" + twoDigit(t[1]) + ":" + twoDigit(t[2])
  
seconds_string = (num) ->
  t = [0,0,0]
  t[2] = parseInt(num)
  t[1] = t[2] // 60
  t[2] = t[2]  % 60
  t[0] = t[1] // 60
  t[1] = t[1]  % 60
  t_to_string t

parse_24h_t = (str) ->
  str = "" + str # Convert to string
  components = str.replace('.', ':').replace(/[^0-9:]/g, '').split(":")
  t = [0,0,0]
  # Seconds
  t[2] = parseInt(components[2]) if components[2]?
  t[2] = 0 if isNaN(t[2])
  t[1] += t[2] // 60
  t[2] = t[2]%60
  # Minutes
  t[1] += parseInt(components[1]) if components[1]?
  t[1] = 0 if isNaN(t[1])
  t[0] += t[1] // 60
  t[1] = t[1]%60
  # Hours
  t[0] += parseInt(components[0]) if components[0]?
  t[0] = 0 if isNaN(t[0])
  t[0] = t[0] % 24
  t
# ------------

# --- Host-object. Contains all global values for the cue player ---
@host =
  play: off
  ticker_start: Date.now()
  ticker_remaining: 0
  ticker_elapsed: 0
  ticker_over: 0
  ticker_timeout: 0
  current_cue: $()
  live_indicator: $()
  socket: null
  timedif_start: 0
  timedif: 0
  timer_timeout: -1
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


# --- Get current time adjusted ---
time_now = ->
  Date.now() + host.timedif
# ------------

# --- Send playback status to all listening clients ---
send_status = ->
  if host.socket
    # Connected (not checking for actual connection, though, just the object...)
    data =
      play: host.play
      cue_name: host.current_cue.find('.part-name').html()
      next_cue: true
      remaining: host.ticker_remaining
      over: host.ticker_over
    next = host.current_cue.next()
    if next.length
      data.next_cue_name = next.find('.part-name').html()
    else
      data.next_cue = false
    host.socket.send(data)
  else
    console.log("Host: Websocket connection not established!")
# ------------

# --- Cleanly set host.play variable. Updates the play/pause button ---
set_play = (play, ppbutton = $('#live-started .controls .pp')) ->
  if host.play != play
    host.play = play
    if play
      ppbutton.addClass('play')
      ppbutton.html('pause_circle_filled')
    else
      ppbutton.removeClass('play')
      ppbutton.html('play_circle_filled')
      clearTimeout(host.ticker_timeout)
    send_status()
# ------------

# --- Go-To functions. Jump to next/prev/custom cue ---
go_to = (part, refresh = true, send = true) ->
  host.current_cue.attr('id', '')
  restore host.current_cue # Restore previous cue
  host.current_cue = part
  host.ticker_remaining = restore part # Restore part, and set ticker_remaining
  host.ticker_over = 0
  start_ticker() if host.play
  part.attr('id', 'counting')
  refresh_indicator() if refresh
  send_status() if send
  
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
  actual = time_now() - host.ticker_start
  clearTimeout(host.ticker_timeout)
  # Next tick in 1 second +/- correction of any accumulated error
  host.ticker_timeout =
    setTimeout tick_f, 1000 - (actual - host.ticker_elapsed)

tick = -> # Process tick
  if host.play
    host.ticker_elapsed += 1000
    host.ticker_remaining-- if host.ticker_remaining # Ensure that it's not made negative
    t_string = refresh_indicator()
    host.current_cue.find('.part-time').html(t_string)
    if host.ticker_remaining <= 0
      go_to_next(false, false) until host.ticker_remaining > 0 or !host.play
      send_status()
      refresh_indicator()
    schedule_tick tick

start_ticker = ->
  host.ticker_start = time_now()
  # Resuming from pause: Decrease the time to the next step by how much was
  # timed over before pausing (i.e. Paused @ 10.765 -> wait for 765ms less)
  host.ticker_elapsed = - host.ticker_over
  host.ticker_over = 0
  set_play on
  schedule_tick(tick)

pause_ticker = ->
  actual = time_now() - host.ticker_start
  host.ticker_over = actual - host.ticker_elapsed
  set_play off
# ------------

timer_exec = ->
  $('#live-view .controls .timer').html('timer_off')
  $('#timer-indicator').html("Timer off")
  host.timer_timeout = -1
  start_ticker()

timer = (time, human) ->
  $('#live-view .controls .timer').html('timer')
  $('#timer-indicator').html("Starting at #{human}")
  host.timer_timeout =
    setTimeout timer_exec, time - Date.now()

cancel_timer = ->
  clearTimeout(host.timer_timeout)
  host.timer_timeout = -1
  $('#live-view .controls .timer').html('timer_off')
  $('#timer-indicator').html("Timer off")

# --- Load. Executed when the page is loaded (via Tubolinks or otherwise) ---
# Defines all hooks for controls and cue buttons, and initializes the logic
load = ->
  $('#start-live-show').click ->
    # Enter live mode
    $('#live-view').addClass('live')
    urlid = $('#live-urlid').data('urlid')
    host.timedif_start = Date.now()
    host.socket = App.cable.subscriptions.create { channel: "HostChannel", urlid: urlid },
      connected: ->
        send_status() # Send initial status
      received: (data) ->
        if data.timestamp
          # Declare time difference (synchronized with server)
          # Assume, that one-directional delay is two-directional delay / 2
          host.timedif = (data.timestamp - host.timedif_start) / 2
        else
          # Some client requested current status
          send_status()
  
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
  
  controls.find('.timer').click (e) ->
    e.preventDefault()
    if host.timer_timeout == -1
      input = prompt('Enter time for scheduled show play start (format hh:mm:ss).\nIf it is set before the current time, it will start the next day.', '00:00:00')
      if input != null
        t = parse_24h_t input
        now = new Date();
        schedule = new Date();
        schedule.setHours(t[0], t[1], t[2], 0)
        if now > schedule
          schedule.setTime(schedule.getTime() + 86400000) # Increment by one day
        timer schedule, t_to_string(t)
    else
      cancel_timer()
  controls.find('.stop').click (e) ->
    e.preventDefault()
    if confirm($(this).data('confirm-msg'))
      host.socket.unsubscribe()
      $('#live-view').removeClass('live')
  
  host.live_indicator = $('#live-indicator')
  
  # Cue display
  
  # Set initial data-seconds' and contents to time displays
  $('#live-list .part-time').each -> restore_t $(this)
  
  parts = $('#live-list .live-part')
  parts.dblclick ->
    # Jump to this cue
    if host.current_cue != $(this)
      go_to $(this)
      
  if parts.length
    go_to parts.first(), true, false # Start from first part, don't try to send it
  refresh_indicator()

# Turbolinks
$(document).on('turbolinks:load', load)
# ------------
