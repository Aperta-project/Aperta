ETahi.ApplicationController = Ember.Controller.extend
  currentUser:(->
    userId = Tahi.currentUser?.id.toString()
    @store.getById('user', userId)
  ).property().volatile()

  connectToES:(->
    return unless Tahi.currentUser?.id
    params =
      url: '/event_stream'
      method: 'GET'
      success: (data) =>
        data.eventNames.forEach (eventName) =>
          source = new EventSource(data.url + "&stream=#{eventName}")
          Ember.$(window).unload ->
            source.close()
          source.addEventListener eventName, (msg) =>
            esData = JSON.parse(msg.data)
            @pushUpdate(esData)

    Ember.$.ajax(params)
  ).on('init')

  pushUpdate: (esData)->
    Ember.run =>
      # add code for when esData is a message_task
      if esData.task
        phaseId = esData.task.phase_id
        taskId = esData.task.id
        if task = @store.findTask(taskId)
          # This is an ember bug.  A task's phase needs to be notified that the other side of
          # the hasMany relationship has changed via set.  Simply loading the updated task into the store
          # won't trigger the relationship update.
          task.set('phase', @store.getById('phase', phaseId))
          @store.pushPayload('task', esData)
        else
          @store.pushPayload('task', esData)
          task = @store.findTask(taskId)
          phase = @store.getById('phase', phaseId)
          phase.get('tasks').addObject(task)

        task.triggerLater('didLoad')


  overlayBackground: Ember.computed.defaultTo('defaultBackground')

  overlayRedirect: null

  defaultBackground: 'overlay_background'
