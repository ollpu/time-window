# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# This whole blob needs a lot of tidying!

parse_time_t = (str) ->
  str = "" + str # Convert to string
  components = str.replace(/[^0-9:]/g, '').split(":")
  # Unify duration format
  t = [0,0,0]
  s = components.length
  t[2] = parseInt(components[s-1]) if components[s-1]?
  t[2] = 0 if isNaN(t[2])
  t[1] += t[2] // 60
  t[2] = t[2]%60
  t[1] += parseInt(components[s-2]) if components[s-2]?
  t[1] = 0 if isNaN(t[1])
  t[0] += t[1] // 60
  t[1] = t[1]%60
  t[0] += parseInt(components[s-3]) if components[s-3]?
  t[0] = 0 if isNaN(t[0])
  t

time_seconds = (t) ->
  (t[0]*60+t[1])*60+t[2]

twoDigit = (num) ->
  if num > 9
    return "" + num
  else
    return "0" + num

time_string = (t) ->
  twoDigit(t[0]) + ":" + twoDigit(t[1]) + ":" + twoDigit(t[2])

seconds_string = (num) ->
  t = [0,0,0]
  t[2] = parseInt(num)
  t[1] = Math.floor(t[2]/60)
  t[2] = t[2]%60
  t[0] = Math.floor(t[1]/60)
  t[1] = t[1]%60
  time_string t

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
    row = $(this).parent().parent()
    total = $('#total-time')
    val = parseInt(total.data('seconds')) - parseInt(
          row.find('.show_part_time').data('seconds'))
    total.html(seconds_string(val))
         .data('seconds', val)
    row.remove()
  
  # When a time-field is blurred (focused out of), it's format will be parsed
  # and then output again, creating a uniform format of notation and fixing any
  # potential errors
  $('.show_part_time').unbind('blur')
  .blur ->
    me = $(this)
    t = parse_time_t me.val()
    me.val(time_string(t))
    total = parseInt($('#total-time').data('seconds'))
    total -= me.data('seconds')
    me.data('seconds', time_seconds(t))
      .next('.show_part_seconds').val(time_seconds(t))
    total += me.data('seconds')
    $('#total-time').html(seconds_string(total))
                    .data('seconds', total)
owners_hooks = ->
  $('#owners-list .email:not(.self)').unbind('click').click ->
    $(this).remove()
@show_owners_hooks = owners_hooks
load = ->
  $('#new-show-add-part').click (e) ->
    e.preventDefault()
    $('#show-parts-tbody').append $('#new-show-part-template').data('template')
    show_part_time_hooks()
  show_part_time_hooks()
  $('#new-show-parts-tbody').sortable({
    axis: 'y'
  })
  # Get initial total
  total = 0
  $('.show_part_time').each ->
    val = parseInt($(this).next('.show_part_seconds').val())
    $(this).val(seconds_string(val))
           .data('seconds', val)
    total += val
  $('#total-time').html(seconds_string(total))
                  .data('seconds', total)
  
  # Owners-modal
  $('#add-owner-button').click (e) ->
    e.preventDefault()
    email_field = $('#add-owner-name')
    email = email_field.val()
    if email != ''
      $('#owners-list').append "<li class='email' href>#{email}
      <input type='hidden' value='#{email}' name='show[owners][]'></li>"
      owners_hooks()
      email_field.val('')
  owners_hooks()
  $('#manage-owners').on 'open-modal-handle', ->
    # Populate the owners-modal when opened
    me = $(this)
    $.get me.prop('action'), (data) ->
      $('#owners-list').html(data)
      show_owners_hooks()
  .submit ->
    me = $(this)
    $('#add-owner-button').click()
    $.post(me.prop('action'), me.serialize(), ->
      $('#manage-owners').trigger 'close-modal'
    ).fail (xhr, status) ->
      if xhr.status == 422
        # Some emails were invalid
        $('#owners-list').html(xhr.responseText)
        $('#manage-owners').trigger 'modal-error', 'Some of the emails are not linked to any account. Try again.'
        show_owners_hooks()
      else
        # Unhandleable error
        $('#manage-owners').trigger 'modal-error', "An unexpected error occured: #{status}"
  
# Turbolinks
$(document).on('turbolinks:load', load)
