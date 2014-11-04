interval = 500
ETahi.EventStream = Em.Object.extend
  eventSource: null
  eventNames: null
  messageQueue: null
  wait: false
  init: ->
    @set('messageQueue', [])
    @resetChannels()
    @processMessages()

  addEventListener: (eventName) ->
    @get('eventSource').addEventListener eventName, @msgEnqueue.bind(@)

  msgEnqueue: (msg) ->
    @get('messageQueue').unshiftObject(msg)

  processMessages: ->
    unless @get('wait')
      if msg = @messageQueue.popObject()
        msg.parsedData = JSON.parse(msg.data)
        if @shouldProcessMessage(msg)
          description = "Event Stream: #{msg.parsedData.subscription_name} -> #{msg.parsedData.action}"
          Tahi.utils.debug(description, msg)
          @msgResponse(msg.parsedData)
    Ember.run.later(@, 'processMessages', [], interval)

  shouldProcessMessage: (msg) ->
    @get('eventNames').contains(msg.type) or msg.parsedData.action == 'destroyed'

  pause: ->
    @set('wait', true)

  play: ->
    @set('wait', false)

  stop: ->
    @get('eventSource').close() if @get('eventSource')

  resetChannels: ->
    @pause()
    @stop()
    params =
      url: '/event_stream'
      method: 'GET'
      success: (data) =>
        return if data.enabled == 'false'
        @set('eventSource', new EventSource(data.url))
        Ember.$(window).unload => @stop()
        @set('eventNames', data.eventNames)
        Tahi.utils.debug("Event Stream: updated channels", data.eventNames)
        data.eventNames.forEach (eventName) =>
          @addEventListener(eventName)
        @play()
    Ember.$.ajax(params)

  msgResponse: (esData) ->
    action = esData.action
    meta = esData.meta
    delete esData.meta
    delete esData.action
    delete esData.subscription_name
    if meta
      @eventStreamActions["meta"].call(@, meta.model_name, meta.id)
    else
      (@eventStreamActions[action] || ->).call(@, esData)

  createOrUpdateTask: (action, esData) ->
    taskId = esData.task.id
    if oldTask = @store.findTask(taskId)
      oldPhase = oldTask.get('phase')
    @store.pushPayload('task', esData)
    task = @store.findTask(taskId)
    phase = task.get("phase")
    if action == 'created'
      # This is an ember bug.  A task's phase needs to be notified that the other side of
      # the hasMany relationship has changed via set.  Simply loading the updated task into the store
      # won't trigger the relationship update.
      phase.get('tasks').addObject(task)
    if action == 'updated' && phase != oldPhase
      phase.get('tasks').addObject(task)
      oldPhase.get('tasks').removeObject(oldTask) if oldPhase
      task.set('phase', phase)

    task.triggerLater('didLoad')

  applicationSerializer: (->
    @store.container.lookup("serializer:application")
  ).property()

  eventStreamActions:
    created: (esData) ->
      Ember.run =>
        if esData.task
          @createOrUpdateTask('created', esData)
        else
          @store.pushPayload(esData)

    updated: (esData)->
      Ember.run =>
        if esData.task
          @createOrUpdateTask('updated', esData)
        else
          @store.pushPayload(esData)

    destroyed: (esData)->
      for key of esData
        type = @get('applicationSerializer').typeForRoot(key)
        esData[key].forEach (id) =>
          if type == "task"
            record = @store.findTask(id)
          else
            record = @store.getById(type, id)
          if record
            record.unloadRecord()

    meta: (modelName, id) ->
      Ember.run =>
        if model = @store.getById(modelName, id)
          model.reload()
        else
          @store.find(modelName, id)

    updateStreams: ->
      @resetChannels()

