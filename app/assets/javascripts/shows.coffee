# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

show_part_time_hooks = ->
  # Hooks for the drag handle
  handle = $('.show-part-action')
  handle.unbind('click')
  handle.click (e) ->
    e.preventDefault()
  handle.attr('tabindex', -1)
  
  $('.show-part-delete').unbind('click');
  $('.show-part-delete').click (e) ->
    e.preventDefault()
    $(this).parent().parent().remove()
  
  # When a time-field is blurred (focused out of), it's format will be parsed
  # and then output again, creating a uniform format of notation and fixing any
  # potential errors
  $('.show_part_time').unbind('blur')
  $('.show_part_time').blur ->
    components = $(this).val().replace(/[^0-9:]/g, '').split(":")
    # Unify duration format
    t = [0,0,0]
    s = components.length
    t[2] = parseInt(components[s-1]) if components[s-1]?
    t[2] = 0 if isNaN(t[2])
    t[1] += Math.floor(t[2]/60)
    t[2] = t[2]%60
    t[1] += parseInt(components[s-2]) if components[s-2]?
    t[1] = 0 if isNaN(t[1])
    t[0] += Math.floor(t[1]/60)
    t[1] = t[1]%60
    t[0] += parseInt(components[s-3]) if components[s-3]?
    t[0] = 0 if isNaN(t[0])
    twoDigit = (num) ->
      if num > 9
        return "" + num
      else
        return "0" + num
    $(this).val(twoDigit(t[0]) + ":" + twoDigit(t[1]) + ":" + twoDigit(t[2]))

load = ->
  $('#new-show-add-part').click (e) ->
    e.preventDefault()
    $('#new-show-parts tbody').append(
      $('#new-show-part-template').data('names-field')
    )
    show_part_time_hooks()
  show_part_time_hooks()
  $('#new-show-parts tbody').sortable({
    axis: 'y'
  })
  
  
# Turbolinks
$(document).on('turbolinks:load', load)
