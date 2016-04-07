
load = ->
  $('.open-modal').click (e) ->
    e.preventDefault()
    modal = $("##{$(this).data('modal-id')}")
    modal.removeClass('closed')
  $('.close-modal').click (e) ->
    e.preventDefault()
    modal = $("##{$(this).data('modal-id')}")
    modal.addClass('closed')

# Turbolinks
$(document).on('turbolinks:load', load)
