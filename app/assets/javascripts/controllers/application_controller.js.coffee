ETahi.ApplicationController = Ember.Controller.extend
  currentUser:(->
    userId = Tahi.currentUser?.id.toString()
    @store.getById('user', userId)
  ).property().volatile()

  connectToES:(->
    return unless Tahi.currentUser?.id
    store = @store
    params =
      url: '/event_stream'
      method: 'GET'
      success:(data)->
        source = new EventSource(data.url)
        data.eventNames.forEach (eventName)->
          source.addEventListener eventName, (msg)->
            esData = JSON.parse(msg.data)
            Ember.run ->
              type = esData.type.replace(/.+::/, '')
              delete esData.type
              store.pushPayload(type, esData)

              if esData.task
                store.find('task', esData.task.id).then (task)->
                  # ember.js bug:  need to tell phase about any new tasks
                  task.get('phase').get('tasks').pushObject(task)

    Ember.$.ajax(params)
  ).on('init')

  overlayBackground: Ember.computed.defaultTo('defaultBackground')

  overlayRedirect: null

  defaultBackground: 'overlay_background'
