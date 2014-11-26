interval = 500
ETahi.EventStream = Em.Object.extend
  eventSource: null
  channels: null
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
        # TODO: log the request to get the payload
        @processMessage(msg)
    Ember.run.later(@, 'processMessages', [], interval)

  processMessage: (msg) ->
    params =
      url: msg.data
      method: 'GET'
      success: (data) =>
        description = "Event Stream triggered from #{data.subscription_name}"
        Tahi.utils.debug(description, data)
        @msgResponse(data)
        @play()
    Ember.$.ajax(params)

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
        @set('channels', data.channels)
        Tahi.utils.debug("Event Stream: updated channels", data.channels)
        data.channels.forEach (eventName) =>
          @addEventListener(eventName)
        @play()
    Ember.$.ajax(params)

  msgResponse: (esData) ->
    action = esData.action
    delete esData.action
    delete esData.subscription_name
    (@eventStreamActions[action] || -> null).call(this, esData)

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
      type = @get('applicationSerializer').typeForRoot(esData.type)
      esData.ids.forEach (id) =>
        if type == "task"
          record = @store.findTask(id)
        else
          record = @store.getById(type, id)
        if record
          record.unloadRecord()
