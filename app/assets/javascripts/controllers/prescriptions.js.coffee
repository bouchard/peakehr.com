$ ->

  $(document).on 'page:load', ->

    if $('body').hasClass('prescriptions')

      $.flashPrescriptionMessage = (msg, type = 'alert', vanishing = true) ->
        # TODO: implement vanishing.
        $('#new_prescription .flash-container').find(".#{type}").remove()
        $('#new_prescription .flash-container').append($("<div class='#{type}'>#{msg}</div>"))

      $.checkSuggestedDosing = (drug) ->
        $.ajax(
          url : "/patients/#{window.clientSideState.patient_id}/prescriptions/check_suggested_dosing"
          data :
            'drug' : drug
          dataType : 'json'
        ).done( (d) ->
          $.flashPrescriptionMessage("Suggested initial dosing is: #{d['suggested_dose_range']}", 'suggested-dose')
        )

      $('#prescription_pretty_start_date').pickadate
        format : 'mmmm dd, yyyy'
      $('#prescription_name').autocomplete
        serviceUrl : "/patients/#{window.clientSideState.patient_id}/prescriptions/autocomplete/"
        offsetTop: -2
        deferRequestBy : 50
        paramName : 's'
        onSelect : (suggestion) ->
          # Need a setTimeout here as a tab keypress on Chrome
          # overrides our next-field focus and goes to what it think
          # should be the next focus.
          that = $(this)
          setTimeout(->
            inputs = that.closest('form').find(':input')
            inputs.eq(inputs.index(that) + 1).focus()
          , 1)
          $.checkSuggestedDosing(that.val())
          $.checkStudyEligibility('new_prescription', 'intention_to_treat', that.val()).done( (study) ->
            $.flashPrescriptionMessage(JST['templates/intention-to-treat-notice'](study: study), 'study-enrollment')
          )

      $('#prescription_name').focus()
      $.checkSuggestedDosing($('#prescription_name').val())

  $(document).on 'page:receive', ->
