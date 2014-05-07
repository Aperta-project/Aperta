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
        container.register('user:current', ->
          @store.getById('user', currentUserId)
        , instantiate: false)
        application.inject('controller', 'getCurrentUser', 'user:current')
        application.inject('route', 'getCurrentUser', 'user:current')
        ETahi.advanceReadiness()
      ).then(null, (error) -> window.location.replace('/users/sign_in'))
