$ ->

  $.fn.slideOut = ->
    el = $(this)
    el.animate(left : - el.outerWidth(), 200)
    el

  $.fn.slideIn = ->
    el = $(this)
    el.animate(left : 0, 200)
    el

  $(document).on 'page:load', ->

    if $('body').hasClass('schedules')

      calendar = $('#calendar')
      timetable = $('#timetable')
      calendar.html('')
      timetable.html('')

      calendar.html(JST['templates/calendar'](
        date : window.clientSideState.schedule_data.earliest_time_to_display
      ))
      timetable.html(JST['templates/timetable'](
        calendars : window.clientSideState.schedule_data.calendars
        earliest_time_to_display : window.clientSideState.schedule_data.earliest_time_to_display
        latest_time_to_display : window.clientSideState.schedule_data.latest_time_to_display
        appointment_interval : window.clientSideState.schedule_data.appointment_interval
      ))
      # Make all the rows equal height. Easier to do this in JS than to fight with the CSS.
      maxHeight = _.max($('> table > tbody > tr > td', timetable).map(->
        $(this).height()
      ))
      $('> table > tbody > tr > td', timetable).css(
        height: maxHeight
      )

      timetable.on 'click.appointment', '.appointment', ->
        Turbolinks.visit('/patients/' + $(this).data('id'))

      # Let users click anywhere in the cell to go to the next one.
      calendar.on 'click.calendar', 'td', (e) ->
        Turbolinks.visit($(this).find('a').attr('href'))
        e.preventDefault()

  $(document).on 'page:receive', ->