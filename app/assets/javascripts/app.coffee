
load = ->
  $('#open-menu').unbind('click').click (e) ->
    $('#side-menu').toggleClass('open')
  
  $('#side-menu li a').unbind('click').click ->
    $('#side-menu').removeClass('open')
    
$(document).on('turbolinks:load', load)
