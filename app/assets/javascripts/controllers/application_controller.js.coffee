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

  showAdminLinks: (->
    return unless @get('currentUser')
    Ember.$.ajax
      url: "/admin/journals"
      method: 'GET'
      success: (data) =>
        @set('canViewAdminLinks', true)
      fail: (data) =>
        #no-op
  ).on('init')

  # this will get overridden by inject except in testing cases.
  getCurrentUser: -> null

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
            delete esData.action
            (ETahi.EventStreamActions[action]||->).call(@, esData)

    Ember.$.ajax(params)
  ).on('init')

  overlayBackground: Ember.computed.defaultTo('defaultBackground')

  overlayRedirect: null

  defaultBackground: 'overlay_background'
