$ ->
  $(document).on 'page:load', ->

    searchBar = $('#search-content')
    if searchBar.length > 0
      searchBar.on 'focus.search-bar', ->
        window.originalSearchBarContent = $(this).html()
        window.savedSearchBarContent ||= $(this).html()
        $(this).html(window.savedSearchBarContent)
        # Clean the random <br> tags that seem to get inserted in Chrome.
        $(this).html($(this).text())
        # Ugly ass code to get the whole field's text highlighted on focus.
        that = $(this)
        window.setTimeout(->
          if window.getSelection && document.createRange
            range = document.createRange()
            range.selectNodeContents(that.get(0))
            sel = window.getSelection()
            sel.removeAllRanges()
            sel.addRange(range)
          else if document.body.createTextRange
            range = document.body.createTextRange()
            range.moveToElementText(that.get(0))
            range.select()
        , 1)

      searchBar.on 'blur.search-bar', ->
        if $(this).html() != window.originalSearchBarContent
          window.savedSearchBarContent = $(this).html()
          $(this).html(window.originalSearchBarContent)

    searchBar.autocomplete
      containerClass : 'autocomplete-suggestions searchbar'
      serviceUrl : '/autocomplete/'
      width : 350
      offsetTop : 17
      deferRequestBy : 50
      paramName : 's'
      onSelect : (suggestion) ->
        Turbolinks.visit(suggestion.url)

  $(document).on 'page:receive', ->

    window.savedSearchBarContent = null
    searchBar = $('#search-content')
    searchBar.off 'focus.search-bar, blur.search-bar, keydown.autocomplete, keyup.autocomplete, blur.autocomplete, focus.autocomplete, change.autocomplete'