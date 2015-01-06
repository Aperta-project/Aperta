ETahi.initializer
  name: 'currentUser'
  after: 'store'
  initialize: (container, application) ->
    if window.currentUserId
      ETahi.deferReadiness()
      store = container.lookup('store:main')
      store.find 'user', window.currentUserId
      .then (user) ->
        container.register('user:current', ->
          user
        , instantiate: false)
        application.inject('controller', 'getCurrentUser', 'user:current')
        application.inject('route', 'getCurrentUser', 'user:current')
        ETahi.advanceReadiness()
      .catch (error) ->
        window.location.replace('/users/sign_in')
