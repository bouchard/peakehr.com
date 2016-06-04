$ ->

  $.fn.textWithLinebreaks = ->
    breakToken = 'T8VQ1O478J'
    lineBreakedHtml = $(this).html().replace(/<br\s?\/?>/gi, breakToken).replace(/<p\.*?>(.*?)<\/p>/gi, breakToken + '$1' + breakToken)
    return $('<div>').html(lineBreakedHtml).text().replace(new RegExp(breakToken, 'g'), '\n')

  # More complicated than it needs to be so we can get position within contenteditable as well.
  $.fn.getCursorPosition = ->
    range = window.getSelection().getRangeAt(0)
    treeWalker = document.createTreeWalker(
      this[0],
      NodeFilter.SHOW_TEXT,
      (node) ->
        nodeRange = document.createRange()
        nodeRange.selectNodeContents(node)
        if nodeRange.compareBoundaryPoints(Range.END_TO_END, range) < 1 then NodeFilter.FILTER_ACCEPT else NodeFilter.FILTER_REJECT
      , false
    )

    charCount = 0
    charCount += treeWalker.currentNode.length while treeWalker.nextNode()
    charCount += range.startOffset if range.startContainer.nodeType == 3
    console.log(charCount)
    charCount

  $.shortAgeInWords = (birthDate) ->
    today = new Date()
    birthDate = new Date(birthDate)
    age = today.getFullYear() - birthDate.getFullYear()
    m = today.getMonth() - birthDate.getMonth()
    age-- if m < 0 || (m == 0 && today.getDate() < birthDate.getDate())
    if age == 0 then "#{m}m" else "#{age}y"

  $.fn.insertAtSavedCursorPosition = (text) ->
    cursorPosition = this.parents('article').data('cursor-position') || 0
    this.text(this.text().substring(0, cursorPosition) + text + this.text().substring(cursorPosition))
    $(this[0]).focus()
    this.setCursorPosition(cursorPosition + text.length)

  $.fn.setCursorPosition = (pos = 0) ->
    this.setSelection(0, 0)
    return this

  $.fn.setSelection = (start = 0, end = 0) ->
    this.each (index, elem) ->
      sel = window.getSelection()
      range = document.createRange()
      range.collapse(true)
      range.setStart($(this).get(0).childNodes[0] || $(this).get(0), start)
      range.setEnd($(this).get(0).childNodes[0] || $(this).get(0), end)
      sel.removeAllRanges()
      sel.addRange(range)
    return this

  # Need to reset the cursor position for a seamless experience after inserting HTML into the body.
  $.fn.resetSelection = ->
    this.each (index, elem) ->
      cursorPosition = $(this).parents('article').data('cursor-position') || 0
      $(this).setSelection(cursorPosition, cursorPosition)
    return this

  $.fn.selectNextToken = ->
    range = document.body.createTextRange()
    range.moveToElementText($(this).get(0))
    range.select()
    # sel = window.getSelection()
    # sel.removeAllRanges()
    # sel.addRange(range)

  $.checkStudyEligibility = (trigger, study_type, value) ->
    $.ajax(
      url : "/patients/#{window.clientSideState.patient_id}/enrollments/check_eligibility"
      data :
        'trigger' : trigger
        'value' : value
        'study_type' : study_type
      dataType : 'json'
    )

  $.flashMessage = (msg, type = 'alert', vanishing = true) ->
    # TODO: implement vanishing.
    $('#flash-container').append($("<div class='#{type}'>#{msg}</div>"))

  # Pick up the client timezone for localtime conversions on the site.
  utcOffset = (new Date()).getTimezoneOffset()
  $.cookie('utc_offset', utcOffset, { path : '/', expires : 365 })

  # Shim until the HTML5 DOM Event 'input' is supported by more browsers, so we can just check
  # for changes directly on contenteditable.
  $(document)
    .on 'focus', '[contenteditable]', ->
      $(this).data 'before', $(this).html()
    .on 'blur keyup paste', '[contenteditable]', ->
      if $(this).data('before') != $(this).html()
        $(this).data 'before', $(this).html()
        $(this).trigger 'change'

  $.timeago.settings.allowFuture = true

  $(document).on 'page:load', ->

    $('time.timeago').timeago()
    $('a[rel*=facebox]').facebox()

  $(document).on 'page:fetch', ->
    NProgress.start()
  $(document).on 'page:change', ->
    NProgress.done()
    $.facebox.unload()
    $.facebox.settings.inited = false
    # TODO: Hopefully Turbolinks will start updating HTML tag attributes.
    # For now, copy from the body tag.
    $('html').attr('class', $('body').attr('class'))
  $(document).on 'page:restore', ->
    NProgress.remove()