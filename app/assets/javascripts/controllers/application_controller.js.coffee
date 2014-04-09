ETahi.ApplicationController= Ember.Controller.extend
  currentUser:(->
    userId = Tahi.currentUser?.id.toString()
    @store.getById('user', userId)
  ).property().volatile()

  connectToES:(->
    store = @store
    params =
      url: '/event_stream'
      method: 'GET'
      success:(data)->
        source = new EventSource(data.url)
        data.eventNames.forEach (eventName)->
          source.addEventListener eventName, (msg)->
            esData = JSON.parse(msg.data)
            store.pushPayload(esData.task.type, esData)

    Ember.$.ajax(params)
  ).on("init")

  overlayBackground: Ember.computed.defaultTo('defaultBackground')

  overlayRedirect: null

  defaultBackground: 'overlay_background'
