window.Tahi ||= {}
Tahi.utils =
  camelizeKeys: (object) ->
    camelized = {}
    Ember.keys(object).forEach (key) ->
      camelized[Ember.String.camelize(key)] = object[key]
    camelized

  windowLocation: (url) ->
    window.location = url

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
      max = 20

    $headers.css('height', max)
    $('.column-content').css('top', max)

  togglePropertyAfterDelay: (obj, prop, startVal, endVal, ms) ->
    obj.set(prop, startVal)
    setTimeout( ->
      Ember.run.schedule("actions", obj, 'set', prop, endVal)
    ms)

  debug: (description, obj) ->
    if ETahi.environment == 'development' || ETahi.environment == 'test' || Ember.testing
      console.groupCollapsed(description)
      console.log(Em.copy(obj, true))
      console.groupEnd()

  deNamespaceTaskType: (typeString) ->
    taskTypeNames = typeString.split '::'
    return typeString if taskTypeNames.length is 1
    return taskTypeNames[1] if taskTypeNames[0] isnt 'Task'
    throw new Error("The task type: '#{typeString}' is not qualified.")
