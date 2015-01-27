`import Ember from 'ember'`

Utils = Ember.Namespace.create
  camelizeKeys: (object) ->
    camelized = {}
    Ember.keys(object).forEach (key) ->
      camelized[Ember.String.camelize(key)] = object[key]
    camelized

  deepCamelizeKeys: (hash) ->
    spelunk = (thing) ->
      return thing if (!thing || typeof thing != 'object')
      return thing.map(spelunk) if (Ember.isArray(thing))

      Ember.keys(thing).reduce (previousValue, key) ->
        previousValue[Ember.String.camelize(key)] = spelunk(thing[key])
        previousValue
      , {}

    spelunk(hash)

  deepJoinArrays: (hash) ->
    spelunk = (thing) ->
      Ember.keys(thing).forEach (key) ->
        return thing if (!thing || typeof thing != 'object')
        if Ember.isArray(thing[key])
          thing[key] = thing[key].join(', ')
        else
          spelunk thing[key]

      thing

    spelunk(hash)

  generateUUID: ->
    d = new Date().getTime()
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c)->
      r = (d + Math.random()*16)%16 | 0
      d = Math.floor(d/16)
      if c == 'x'
        r.toString(16)
      else
        (r&0x7|0x8).toString(16)
    )


  windowLocation: (url) ->
    window.location = url

  windowHistory: ->
    window.history

  resizeColumnHeaders: ->
    headers = $('.column-header')
    return unless headers.length

    wrappers = headers.find('.column-title-wrapper')
    wrappers.css('height', '')

    max = null
    try
      max = Math.max.apply(Math, wrappers.map -> $(this).outerHeight())
    catch error
      max = 20

    wrappers.css 'height', max
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
