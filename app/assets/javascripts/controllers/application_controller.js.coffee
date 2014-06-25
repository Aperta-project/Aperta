ETahi.ApplicationController = Ember.Controller.extend
  currentUser: ( ->
    @getCurrentUser()
  ).property()

  isLoggedIn: ( ->
    !Ember.isBlank(@get('currentUser.id'))
  ).property('currentUser.id')

  isAdmin: Ember.computed.alias 'currentUser.admin'
  username: Ember.computed.alias 'currentUser.username'
  canViewAdminLinks: false

  # this will get overridden by inject except in testing cases.
  getCurrentUser: -> null

  clearError:( ->
    @set('error', null)
  ).observes('currentPath')

  connectToES:(->
    return unless @get('currentUser')
    params =
      url: '/event_stream'
      method: 'GET'
      success: (data) =>
        source = new EventSource(data.url)
        Ember.$(window).unload -> source.close()

        data.eventNames.forEach (eventName) =>
          source.addEventListener eventName, (msg) =>
            esData = JSON.parse(msg.data)
            action = esData.action
            meta = esData.meta
            delete esData.meta
            delete esData.action
            (ETahi.EventStreamActions[action]||->).call(@, esData)
            if meta
              ETahi.EventStreamActions["meta"].call(@, meta.model_name, meta.id)

    Ember.$.ajax(params)
  ).on('init')

  overlayBackground: Ember.computed.defaultTo('defaultBackground')

  overlayRedirect: []

  defaultBackground: 'overlay_background'
