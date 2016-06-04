$ ->

  $(document).on 'page:load', ->

    if $('body').hasClass('medications')

      $('table.medications tr').click(->
        $(this).find('input[type=checkbox]').click()
      )

      if window.clientSideState.print_prescriptions?
        window.open(window.clientSideState.print_prescriptions_path.replace('NULL', window.clientSideState.print_prescriptions))


  $(document).on 'page:receive', ->
