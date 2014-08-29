ETahi.EventStream = Em.Object.extend
  eventSource: null
  init: ->
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

  addEventListener: (eventName) ->
    @get('eventSource').addEventListener eventName, @msgResponse.bind(@)

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
    if action == 'created'
      phase = task.get("phase")
      # This is an ember bug.  A task's phase needs to be notified that the other side of
      # the hasMany relationship has changed via set.  Simply loading the updated task into the store
      # won't trigger the relationship update.
      phase.get('tasks').addObject(task)
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
