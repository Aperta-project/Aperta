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
    (@eventStreamActions[action] || ->).call(@, esData)

  fetchRecords: (action, recordsToLoad)->
    Ember.run =>
      store = @store
      recordsToLoad.forEach ({type, id}) ->
        if type == 'task'
          existingModel = store.findTask(id)
        else
          existingModel = store.getById(type, id)

        if existingModel
          existingModel.reload()
        else
          store.find(type, id).then (newRecord) ->
            if action == 'created' || type == 'task'
              phase = newRecord.get("phase")
              # This is an ember bug.  A task's phase needs to be notified that the other side of
              # the hasMany relationship has changed via set.  Simply loading the updated task into the store
              # won't trigger the relationship update.
              phase.get('tasks').addObject(newRecord)

  eventStreamActions:
    created: (esData) ->
      @fetchRecords('created', esData.records_to_load)

    updated: (esData) ->
      @fetchRecords('updated', esData.records_to_load)

    destroy: (esData)->
      esData.task_ids.forEach (taskId) =>
        task = @store.findTask(taskId)
        if task
          task.deleteRecord()
          task.triggerLater('didDelete')
