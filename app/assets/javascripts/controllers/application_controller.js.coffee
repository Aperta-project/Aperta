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
        source = new EventSource(data.url)
        data.eventNames.forEach (eventName) =>
          source.addEventListener eventName, (msg) =>
            esData = JSON.parse(msg.data)
            @pushUpdate(esData)

    Ember.$.ajax(params)
  ).on('init')

  pushUpdate: (esData)->
    Ember.run =>
      @store.pushPayload('task', esData)
      # add code for when esData is a message_task
      if esData.task
        if task = @store.findTask(esData.task.id)
          # ember.js bug:  need to tell phase about any new tasks
          # make sure the phases tasks are updated.
          task.triggerLater('didLoad')
          task.get('phase').get('tasks').then (taskArray) ->
            taskArray.addObject(task)


  overlayBackground: Ember.computed.defaultTo('defaultBackground')

  overlayRedirect: null

  defaultBackground: 'overlay_background'
