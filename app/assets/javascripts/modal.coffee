
open_hash = ->
  hash = window.location.hash.slice(1)
  if hash.startsWith('m')
    $("##{hash.replace('m-','')}").trigger('open-modal')

load = ->
  $('.open-modal').click (e) ->
    e.preventDefault()
    modal = $("##{$(this).data('modal-id')}")
    modal.trigger('open-modal')
  $('.close-modal').click (e) ->
    e.preventDefault()
    modal = $("##{$(this).data('modal-id')}")
    modal.trigger('close-modal')
  
  $('.modal').on 'open-modal', ->
    modal = $(this)
    modal.trigger('open-modal-handle')
    modal.trigger('modal-error', '') # Reset the error field
    window.location.hash = "m-#{modal.attr('id')}"
    modal.removeClass('closed')
  .on 'close-modal', ->
    modal = $(this)
    modal.addClass('closed')
    modal.trigger('close-modal-handle')
    window.location.hash = ""
  .on 'modal-error', (e, message) ->
    modal = $(this)
    modal.find('.modal-error').html(message)
  .submit ->
    modal = $(this)
    if modal.data('custom-submit')
      false # Don't submit
    else
      modal.trigger('close-modal')
  setTimeout(open_hash, 80)
  
  

# Turbolinks
$(document).on('turbolinks:load', load)
