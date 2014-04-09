ETahi.ApplicationController= Ember.Controller.extend
  currentUser:(->
    userId = Tahi.currentUser?.id.toString()
    @store.getById('user', userId)
  ).property().volatile()

  connectToES:(->
    params =
      url: '/event_stream'
      method: 'GET'
      success:(data)->
        source = new EventSource(data.url)
        # make one connection and listeners for every paper
        data.eventNames.forEach (eventName)->
          source.addEventListener eventName, (msg)->
            data = JSON.parse(msg.data)
            # do something with the data

    Ember.$.ajax(params)
  ).on("init")

  overlayBackground: Ember.computed.defaultTo('defaultBackground')

  overlayRedirect: null

  defaultBackground: 'overlay_background'
