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

# --- Client-object. Contains all global values for the cue player ---
@client =
  play: off
  ticker_start: Date.now()
  ticker_remaining: 0
  ticker_elapsed: 0
  ticker_timeout: 0
  live_indicator: $()
  timedif_start: 0
  timedif: 0
# ------------

refresh_indicator = ->
  client.live_indicator.html(seconds_string(client.ticker_remaining))

# --- Get current time adjusted ---
time_now = ->
  Date.now() + client.timedif
# ------------

# --- Ticker functions (advances the clock every second) ---
schedule_tick = (tick_f) ->
  clearTimeout(client.ticker_timeout)
  actual = time_now() - client.ticker_start
  # Next tick in 1 second +/- correction of any accumulated error
  client.ticker_timeout =
    setTimeout tick_f, 1000 - (actual - client.ticker_elapsed)

tick = -> # Process tick
  if client.play
    client.ticker_elapsed += 1000
    client.ticker_remaining-- if client.ticker_remaining # Ensure that it's not made negative
    refresh_indicator()
    if client.ticker_remaining > 0
      schedule_tick tick

start_ticker = (over) ->
  client.ticker_start = time_now()
  client.ticker_elapsed = -over
  schedule_tick(tick)

pause_ticker = ->
  clearTimeout(client.ticker_timeout)
# ------------

# --- Cleanly set client.play variable ---
set_play = (play, over) ->
  client.play = play
  if play
    start_ticker(over)
  else
    pause_ticker()
# ------------

# --- Load. Executed when the page is loaded (via Tubolinks or otherwise) ---
# Defines all hooks for controls and cue buttons, and initializes the logic
load = ->
  if window.location.pathname.startsWith('/l/')
    client.live_indicator = $('#client-time')
    urlid = $('#client-urlid').data('urlid')
    client.timedif_start = Date.now()
    App.cable.subscriptions.create { channel: "ClientChannel", urlid: urlid },
      received: (data) ->
        if data.timestamp
          # Declare time difference (synchronized with server)
          # Assume, that one-directional delay is two-directional delay / 2
          client.timedif = (data.timestamp - client.timedif_start) / 2
          part_name = $('#client-part-name')
          part_name.html(part_name.data('wait-start'))
        else
          # Received data from host
          client.ticker_remaining = data['remaining']
          refresh_indicator()
          set_play data['play'], data['over']
          $('#client-part-name').html(data['cue_name'])
          $('#client-next-part').html("Next: " +
            if data['next_cue']
              data['next_cue_name']
            else
              "End"
          )

# Turbolinks
$(document).on('turbolinks:load', load)
# ------------
