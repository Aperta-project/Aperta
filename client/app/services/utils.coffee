`import Ember from 'ember'`

Utils = Ember.Namespace.create
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
    titles  = headers.find('.column-title')
    return unless headers.length

    titles.css('height', '')
    heights = titles.map -> $(this).outerHeight()

    max = null
    try
      max = Math.max.apply(Math, heights)
    catch error
      max = 20

    titles.css 'height', max
    $('.column-content').css 'top', headers.first().outerHeight()

  togglePropertyAfterDelay: (obj, prop, startVal, endVal, ms) ->
    obj.set(prop, startVal)
    setTimeout( ->
      Ember.run.schedule('actions', obj, 'set', prop, endVal)
    ms)

  debug: (description, obj) ->
    # EMBERCLI TODO - use embercli ENV
    if true
      console.log('FIX Etahi.environment')
    else
      if ETahi.environment == 'development' || ETahi.environment == 'test' || Ember.testing
        console.groupCollapsed(description)
        console.log(Em.copy(obj, true))
        console.groupEnd()

  deNamespaceTaskType: (typeString) ->
    taskTypeNames = typeString.split '::'
    return typeString if taskTypeNames.length is 1
    return taskTypeNames[1] if taskTypeNames[0] isnt 'Task'
    throw new Error("The task type: '#{typeString}' is not qualified.")

`export default Utils`
