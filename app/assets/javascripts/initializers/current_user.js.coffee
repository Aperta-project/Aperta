ETahi.initializer
  name: 'currentUser'
  after: 'store'
  initialize: (container, application) ->
    if window.loggedIn
      ETahi.deferReadiness()
      Ember.$.getJSON('/users/profile').then((data) =>
        currentUserId = data.user.id
        store = container.lookup('store:main')
        store.pushPayload 'user', data
        container.register('foo:current', ->
          @store.getById('user', currentUserId)
        , instantiate: false)
        application.inject('controller', 'getCurrentUser', 'foo:current')
        application.inject('route', 'getCurrentUser', 'foo:current')
        ETahi.advanceReadiness()
      , (error) -> null
      )
