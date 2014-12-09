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

  resizeColumnHeaders: ->
    headers = $('.column-header')
    return unless headers.length

    wrappers = headers.find('.column-title-wrapper')
    wrappers.css('height', '')
    heights = wrappers.find('.column-title-wrapper').map ->
      $(this).outerHeight()

    max = null
    try
      max = Math.max.apply(Math, heights)
    catch error
      max = 20

    wrappers.css 'height', max
    $('.column-content').css 'top', headers.first().outerHeight()

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
