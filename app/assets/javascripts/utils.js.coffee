window.Tahi ||= {}
Tahi.utils =
  toCamel: (string) ->
    string.replace /(\-[a-z])/g, ($1) ->
      $1.toUpperCase().replace "-", ""

  windowHistory: ->
    window.history

  bindColumnResize: ->
    $(window).off('resize.columns').on 'resize.columns', =>
      @resizeColumnHeaders()

  resizeColumnHeaders: ->
    $headers = $('.columns .column-header')
    return unless $headers.length

    $headers.css('height', '')
    heights = $headers.find('h2').map ->
      $(this).outerHeight()

    max = null
    try 
      max = Math.max.apply(Math, heights)
    catch error
      console.log "Math error, setting height to 20"
      console.log error
      max = 20

    $headers.css('height', max)
    $('.column-content').css('top', max)

  togglePropertyAfterDelay: (obj, prop, startVal, endVal, ms) ->
    obj.set(prop, startVal)
    setTimeout( ->
      Ember.run.schedule("actions", obj, 'set', prop, endVal)
    ms)

  debug: (description, obj) ->
    if ETahi.environment == 'development'
      console.groupCollapsed(description)
      console.log(obj)
      console.groupEnd()
