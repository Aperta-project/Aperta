ETahi.ApplicationController = Ember.Controller.extend
  currentUser: ( ->
    @getCurrentUser()
  ).property()

  isLoggedIn: ( ->
    !Ember.isBlank(@get('currentUser.id'))
  ).property('currentUser.id')

  isAdmin: Ember.computed.alias 'currentUser.admin'
  username: Ember.computed.alias 'currentUser.username'

  # this will get overridden by inject except in testing cases.
  getCurrentUser: -> null

  connectToES:(->
    return unless @get('currentUser')
    params =
      url: '/event_stream'
      method: 'GET'
      success: (data) =>
        data.eventNames.forEach (eventName) =>
          source = new EventSource(data.url + "&stream=#{eventName}")
          Ember.$(window).unload -> source.close()
          source.addEventListener eventName, (msg) =>
            esData = JSON.parse(msg.data)
            action = esData.action
            delete esData.action
            (ETahi.EventStreamActions[action]||->).call(@, esData)

    Ember.$.ajax(params)
  ).on('init')

  overlayBackground: Ember.computed.defaultTo('defaultBackground')

  overlayRedirect: null

  defaultBackground: 'overlay_background'
