$ ->

  $(document).on 'page:load', ->

    if $('body').hasClass('patients')

      # Listen to new attachments.
      $.eventSource.subscribe('new_attachment', (e) ->
        console.log('woot')
        attachmentAdded()
      )

      # Capture TABs in article bodies.
      $(document).on 'keydown.stamp', 'article .body', (e) ->
        if e.which == 9
          e.preventDefault()
          console.log('woot')


      # Disable the nav if we don't have an editable encounter at the moment.
      $('nav').find('.new-stamp, .new-calculation').addClass('disabled') if $('article[data-type=encounter]:not([data-state=signed_off]):not(:hidden)').length == 0

      # Open/close encounters with JS rather than through CSS display: none'ing.
      $('.articles article').filter('[data-state=signed_off]').children('.accordion').hide()

      # Slide up and down to close/up encounters.
      $(document).on 'click.patients', '.articles header', ->
        accordion = $(this).parents('article').children('.accordion')
        if accordion.is(':visible')
          accordion.slideUp(100)
        else
          accordion.slideDown(100)

      # Slide up and down whole categories of encounters.
      $(document).on 'click.patients', '.articles .square', ->
        accordion = $(this).parent().parent('article').children('.accordion')
        articleType = $(this).parent().parent('article').data('type')
        allArticles = $(".articles article[data-state=signed_off]").find('.accordion')
        if accordion.is(':visible')
          allArticles.slideUp(100)
        else
          allArticles.not($(".articles article[data-type=#{articleType}]").children('.accordion')).slideUp(100)
          $(".articles article[data-type=#{articleType}]").children('.accordion').slideDown(100, ->
            $(window).scrollTop(4 - 33 - 50 + accordion.parent('article').position().top)
          )
        false

      # Attachments email address generation.
      $(document).on 'click.paperclip', 'article:not([data-state=signed_off]) .fa-paperclip', (event) ->
        $(this).qtip(
          overwrite : false
          style :
            classes : 'qtip-large qtip-twi'
          # position:
          #   adjust :
          #     mouse : false
          show :
            event : event.type
            ready : true
          hide :
            delay : 1000
            fixed : true
          content :
            text : (event, api) ->
              api.set('content.title', 'Attach a photo <a href="/help/attach_photo" target="_blank">[?]</a>')
              $.ajax(
                type : 'POST'
                url  : '/dropboxes'
                contentType : 'application/json'
                data :
                  JSON.stringify(
                    'encounter_id' : $(this).parents('article').data('id')
                  )
              ).done((data) ->
                api.set('content.text', "Send a photo via email with the code <span class='code'>#{data.code}</span> somewhere in it to your unique dropbox address:<span class='email'>#{data.email_address}</span>")
              )
              # '<div class="spinner"><div class="spinner-icon"></div></div>'
              'Loading...'
        , event)
        return false

      # Fix the sidebar to not scroll out of frame.
      $(window).on 'scroll.patients', ->
        asideHeight = $('aside').outerHeight()
        articleHeight = $('.articles').outerHeight()
        topOffset = $(window).scrollTop()
        topOffset = articleHeight - asideHeight if topOffset + asideHeight > articleHeight
        topOffset = 0 if topOffset < 0
        $('aside').css
          'top' : topOffset

      # Scroll to bottom of page on first load.
      # Only if we have exactly two class names (a.k.a. not for child controllers),
      # like prescriptions / medications.
      if $('body').attr('class').split(/\s+/).length == 2
        $('html, body').animate(
          scrollTop : $('#main').height()
        , 1000)

      $(document).on 'click.patients', 'nav a', ->
        return false if $(this).hasClass('disabled')
        if $(this).hasClass('new-calculation')
          $.facebox(JST['templates/calculator-menu']())
          $(document).off 'click.calculator'
          $(document).on 'click.calculator', '.calculator-menu-facebox a', ->
            setupFramingham() if $(this).attr('rel') == 'framingham'
            setupWHOChart() if $(this).attr('rel') == 'who-chart'
            return false
        else if $(this).hasClass('new-letter')
          currentLetter.new()
        else if $(this).hasClass('new-stamp')
          $.facebox(JST['templates/stamp']())
          loadStamps()
          unless window.userStamps
            $.ajax(
              type : 'GET'
              url  : '/stamps'
              contentType : 'application/json'
            ).done((data) ->
              loadStamps(data)
            )
        else
          return true
        return false

      loadStamps = (s) ->
        window.userStamps = s if s
        return false unless window.userStamps
        stampDiv = $('.stamp-facebox')
        return false if stampDiv.is(':hidden')
        stampDiv.find('.spinner').hide()
        stampDiv.find('table').show()
        listItems = _.map(window.userStamps, (s) ->
          $('<li>').html(s.title).data('id', s.id)
        )
        $(document).off 'click.stamp'
        $(document).on 'click.stamp', '.stamp-list li', ->
          that = $(this)
          stamp = _.select(window.userStamps, (s) ->
            s.id == that.data('id')
          )[0]
          currentEncounter.insertText(stamp.body)
          currentEncounter.find().resetSelection()
          $(document).trigger 'change.articles'
          $(document).trigger 'close.facebox'
        $(document).off 'mouseover.stamp'
        $(document).on 'mouseover.stamp', '.stamp-list li', ->
          that = $(this)
          stamp = _.select(window.userStamps, (s) ->
            s.id == that.data('id')
          )[0]
          stampDiv.find('.preview').text(stamp.body)
        $(document).off 'mouseout.stamp'
        $(document).on 'mouseout.stamp', '.stamp-list li', ->
          stampDiv.find('.preview').text('')

        stampDiv.find('.stamp-list').append(listItems)

      setupFramingham = ->
        $.facebox(JST['templates/framingham']())
        $(document).on 'change.calculator', '.calculator-facebox.framingham', ->
          # Framingham Algorithm.
          fr = $($(this)[0])
          sex = fr.find('[name=sex] :selected').val()
          age = _.parseInt(fr.find('[name=age] :selected').val())
          tc = _.parseInt(fr.find('[name=tc] :selected').val())
          hdl = _.parseInt(fr.find('[name=hdl] :selected').val())
          bp = _.parseInt(fr.find('[name=bp] :selected').val())
          diabetic = if fr.find('[name=diabetic]').is(':checked') then 1 else 0
          smoker = if fr.find('[name=smoker]').is(':checked') then 1 else 0
          famhx = if fr.find('[name=famhx]').is(':checked') then 1 else 0
          return if _.contains([sex, age, tc, hdl, bp], '') || _.some([sex, age, tc, hdl, bp], _.isNaN)
          if sex == 'm'
            smoker = if smoker == 1 then 2 else 0
            diabetic = if diabetic == 1 then 2 else 0
            age = age - 1
            tc = [-3, 0, 1, 2, 3][tc]
            hdl = [2, 1, 0, 0, -2][hdl]
            bp = [0, 0, 1, 2, 3][bp]
            total = smoker + diabetic + age + tc + hdl + bp
            heartAge = [30, 32, 34, 36, 38, 40, 42, 45, 48, 51, 54, 57, 60, 64, 68, 72, 76][total]
            heartAge = '<30' if total < 0
            heartAge = '>80' if total >= 17
            percentage = [3, 3, 4, 5, 7, 8, 10, 13, 16, 20, 25, 31, 37, 45][total]
            percentage = '>53' if total >= 14
            percentage = 2 if total <= -1
          else
            smoker = if smoker == 1 then 2 else 0
            diabetic = if diabetic == 1 then 4 else 0
            age = [-9, -4, 0, 3, 6, 7, 8, 8, 8][age]
            tc = [-2, 0, 1, 1, 3][tc]
            hdl = [5, 2, 1, 0, -3][hdl]
            bp = [-3, 0, 0, 2, 3][bp]
            total = smoker + diabetic + age + tc + hdl + bp
            heartAge = ['<30', 31, 34, 36, 39, 42, 45, 48, 51, 55, 59, 64, 68, 73, 79][total]
            heartAge = '<30' if total < 1
            heartAge = '>80' if total >= 15
            percentage = [2, 2, 3, 3, 4, 4, 5, 6, 7, 8, 10, 11, 13, 15, 18, 20, 24][total]
            percentage = '>27' if total >= 17
            percentage = 2 if total == -1
            percentage = 1 if total <= -2
          percentage = percentage * 2 if famhx
          fr.find('.answer-box.risk').html(percentage)
          fr.find('.answer-box.age').html(heartAge)
          fr.find('input[type=submit]').prop('disabled', false)
        $(document).on 'click.calculator', '.calculator-facebox.framingham input[type=submit]', ->
          $(document).trigger 'close.facebox'
          percentage = $($(this)[0]).parent('.framingham').find('.answer-box.risk').html()
          currentEncounter.insertText("Framingham 10 Year Risk: #{percentage}%")
          currentEncounter.scrollTo()

      setupWHOChart = ->
        $.facebox(JST['templates/who-chart']())
        $(document).on 'change.calculator', '.calculator-facebox.who-chart', ->
          d1 = [1,2,3,4,5]
          $.plot('.calculator-facebox.who-chart .chart', [ d1 ])

        # TODO: Remove.
        $('.calculator-facebox.who-chart').trigger('change')

      $(document).on 'close.facebox', ->
        $(document).off '.calculator'

      currentEncounter =
        new : ->
          a = $('article[data-type=encounter]:not([data-state=signed_off]):hidden')
          if a.length == 1
            a.find('.body').show()#.text("S: \nO: \nA: \nP: ")
            $('nav a').removeClass('disabled')
            that = this
            a.slideDown(100, ->
              a.find('.body').setCursorPosition(3)
              currentEncounter.scrollTo()
            )
        find : ->
          a = $('article[data-type=encounter]:not([data-state=signed_off]):not(:hidden)')
          b = a.filter('[data-id=' + this.currentEncounterId + ']') if this.currentEncounterId
          (b && b.last()) || a.last()
        insertText : (text) ->
          this.find().find('.body').insertAtSavedCursorPosition(text)
          this.scrollTo()
        scrollTo : ->
          $('html, body').animate
            scrollTop : this.find().offset().top
          , 300
        setCurrent : (e) ->
          this.currentEncounterId = $(e).data('id')

      currentLetter =
        new : ->
          a = $('article[data-type=letter]:not([data-state=signed_off]):hidden')
          lastLetter = $('article[data-type=letter]:not(:hidden)').last()
          if a.length == 1
            b = a.clone().insertAfter(lastLetter)
            b.slideDown(100, ->
              currentLetter.scrollTo()
            )
        find : ->
          $('article[data-type=letter]:not([data-state=signed_off]):not(:hidden)').last()
        scrollTo : ->
          $('html, body').animate
            scrollTop : this.find().offset().top
          , 300

      $(document).on 'change.articles, mouseup.articles, keyup.articles', 'article[data-type=encounter]:not([data-state=signed_off]):not(:hidden) .body', _.debounce(->
        body = $(this)
        article = body.parents('article')
        article.data('cursor-position', body.getCursorPosition())
        currentEncounter.setCurrent(article)
        true
      , 100)

      $(document).on 'change.articles', 'article[data-type=encounter] .body', _.debounce(->
        body = $(this)
        article = body.parents('article')
        id = article.data('id')
        if id && id != ''
          $.ajax(
            type : 'PUT'
            url  : "/encounters/#{id}"
            contentType : 'application/json'
            data :
              JSON.stringify(
                'patient_id' : window.clientSideState.patient_id
                'content' : body.textWithLinebreaks()
              )
          )
        else
          if !article.data('waiting-for-id')
            article.data('waiting-for-id', true)
            $.ajax(
              type : 'POST'
              url  : '/encounters'
              contentType : 'application/json'
              data :
                JSON.stringify(
                  'patient_id' : window.clientSideState.patient_id
                  'content' : body.text()
                )
            ).done((data) ->
              article.data('id', data.id)
              # Push the ID out in an attr too so CSS changes.
              article.attr('data-id', data.id)

              article.find('.title').html(data.title)
            )
      , 500)

      $(document).on 'input.articles', 'article[data-type=letter] textarea', _.debounce(->
        article = $(this).parents('article')
        id = article.data('id')
        to_address = article.find("[name='letter\[to_address\]']")
        content = article.find("[name='letter\[content\]']")
        dlg = window.clientSideState.default_letter_greeting
        if to_address.val().length > 0
          c = _.map(content.val().split(/\n/), (l) ->
            if l.match(new RegExp("^#{dlg}.*"))
              "#{dlg} #{to_address.val().trim().split(/\n/)[0]},"
            else
              l
          )
          content.val(c.join("\n"))
        if id && id != ''
          $.ajax(
            type : 'PUT'
            url  : "/letters/#{id}"
            contentType : 'application/json'
            data :
              JSON.stringify(
                'patient_id' : window.clientSideState.patient_id
                'to_address' : to_address.val()
                'content' : content.val()
              )
            success : (data) ->
              article.find('.title').html(data.title)
          )
        else
          if !article.data('waiting-for-id')
            article.data('waiting-for-id', true)
            $.ajax(
              type : 'POST'
              url  : '/letters'
              contentType : 'application/json'
              data :
                JSON.stringify(
                  'patient_id' : window.clientSideState.patient_id
                  'to_address' : to_address.val()
                  'content' : content.val()
                )
              success : (data) ->
                article.data('id', data.id)
                # Push the ID out in an attr too so CSS changes.
                article.attr('data-id', data.id)
                article.find('.title').html(data.title)
                article.find('a').each ->
                  $(this).attr('href', $(this).attr('href').replace('PLACEHOLDER', data.id))
            )
      , 500)

      $('article:not([data-state=signed_off]) .diagnosis input[type=text]').each ->
        $(this).autocomplete
          serviceUrl : '/encounters/' + $(this).parents('article').data('id') + '/autocomplete/'
          width: 350
          offsetTop: 15
          deferRequestBy : 50
          paramName : 's'
          onSelect : (suggestion) ->
            console.log(suggestion)

      $(document).on 'mouseover.attachment', 'article .attachment', (event) ->
        $(this).qtip(
          overwrite : false
          style :
            classes : 'qtip-large qtip-twi'
          show :
            event : event.type
            ready : true
          hide :
            delay : 250
            fixed : true
          content :
            text : ->
              $(this).attr('title')
        )

      $(document).on 'click.aside-header', 'aside article header', ->
        if $(this).parents('article').attr('href')
          Turbolinks.visit($(this).parents('article').attr('href'))

      $(document).on 'click.new-encounter', '#new-encounter button', ->
        $(this).hide()
        currentEncounter.new()

      $(document).on 'change.most-responsible', '#encounter_working_under_id', ->
        $.ajax(
          type : 'PUT'
          url  : "/session/set_working_under"
          contentType : 'application/json'
          data :
            JSON.stringify(
              'working_under_id' : $(this).find(':selected').val()
            )
          error : ->
            alert('Could not update who you are working under.')
            setTimeout(->
              location.reload()
            , 2000)
        )

      $(document).on 'mouseover.hover-overlay', 'aside article li, aside .demographics', ->
        return true if $(this).find('.hover-overlay').length == 0
        $(this).qtip(
          overwrite : false
          position :
            my : 'right center'
            at : 'left center'
          style :
            classes : 'qtip-large qtip-twi'
          show :
            event : event.type
            ready : true
            delay : 0
            solo  : true
          hide :
            delay : 250
            fixed : true
          content :
            text : ->
              $(this).find('.hover-overlay').html()
        )

  $(document).on 'page:receive', ->

    $(document).off 'click.patients'
    $(document).off 'change.calculator'
    $(document).off 'click.calculator'
    $(document).off 'close.facebox'
    $(document).off 'change.articles'
    $(document).off 'click.meds'
    $(document).off 'click.new-encounter'
    $(window).off   'scroll.patients'
    $(document).off 'keydown.stamp'
    $(document).off 'click.paperclip'
    $(document).off 'mouseover.attachment'
    $(document).off 'mouseover.meds'