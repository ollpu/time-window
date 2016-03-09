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
# ------------

refresh_indicator = ->
  client.live_indicator.html(seconds_string(client.ticker_remaining))

# --- Ticker functions (advances the clock every second) ---
schedule_tick = (tick_f) ->
  clearTimeout(client.ticker_timeout)
  actual = (Date.now()) - client.ticker_start
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

start_ticker = (timestamp, over) ->
  client.ticker_start = timestamp # timestamp = when the host started the ticker
  client.ticker_elapsed = -over
  schedule_tick(tick)

pause_ticker = ->
  clearTimeout(client.ticker_timeout)
# ------------

# --- Cleanly set client.play variable ---
set_play = (play, timestamp, over) ->
  client.play = play
  if play
    start_ticker(timestamp, over)
  else
    pause_ticker()
# ------------

# --- Load. Executed when the page is loaded (via Tubolinks or otherwise) ---
# Defines all hooks for controls and cue buttons, and initializes the logic
load = ->
  if window.location.pathname.startsWith('/l/')
    client.live_indicator = $('#client-time')
    urlid = $('#client-urlid').data('urlid')
    App.cable.subscriptions.create { channel: "ClientChannel", urlid: urlid },
      received: (data) ->
        # Received data from host
        client.ticker_remaining = data['remaining']
        refresh_indicator()
        set_play data['play'], data['timestamp'], data['over']
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
