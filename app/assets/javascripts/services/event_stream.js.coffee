interval = 500
ETahi.EventStream = Em.Object.extend
  eventSource: null
  messageQueue: null
  wait: false
  init: ->
    @set('messageQueue', [])
    params =
      url: '/event_stream'
      method: 'GET'
      success: (data) =>
        return if data.enabled == 'false'
        source = new EventSource(data.url)
        Ember.$(window).unload -> source.close()
        @set('eventSource', source)

        data.eventNames.forEach (eventName) =>
          @addEventListener(eventName)
    Ember.$.ajax(params)
    @processMessages()

  addEventListener: (eventName) ->
    @get('eventSource').addEventListener eventName, @msgEnqueue.bind(@)

  msgEnqueue: (msg) ->
    @get('messageQueue').unshiftObject(msg)

  processMessages: ->
    unless @get('wait')
      msg = @messageQueue.popObject()
      if msg then @msgResponse(msg)
    Ember.run.later(@, 'processMessages', [], interval)

  pause: ->
    @set('wait', true)

  play: ->
    @set('wait', false)

  msgResponse: (msg) ->
    esData = JSON.parse(msg.data)
    action = esData.action
    meta = esData.meta
    delete esData.meta
    delete esData.action
    if meta
      @eventStreamActions["meta"].call(@, meta.model_name, meta.id)
    else
      (@eventStreamActions[action] || ->).call(@, esData)

  createOrUpdateTask: (action, esData) ->
    taskId = esData.task.id
    @store.pushPayload('task', esData)
    task = @store.findTask(taskId)
    # didLoad updates the task's thumbnail
    task.triggerLater('didLoad')

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

    destroy: (esData)->
      esData.task_ids.forEach (taskId) =>
        task = @store.findTask(taskId)
        if task
          task.deleteRecord()
          task.triggerLater('didDelete')

    meta: (modelName, id) ->
      Ember.run =>
        if model = @store.getById(modelName, id)
          model.reload()
        else
          @store.find(modelName, id)
