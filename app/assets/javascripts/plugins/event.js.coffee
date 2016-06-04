$ ->
  $.eventSource =
    init : ->
      return if @esLoaded
      @es = new EventSource('/subscribe')
      @esLoaded = true
    subscribe : (e, func) ->
      @init() unless @esLoaded
      @es.addEventListener(e, func)