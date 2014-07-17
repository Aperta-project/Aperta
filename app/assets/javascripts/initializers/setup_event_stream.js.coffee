ETahi.initializer
  name: 'eventStream'
  after: 'currentUser'
  initialize: (container, application) ->
    if window.currentUserId
      store = container.lookup('store:main')
      es = ETahi.EventStream.extend(store: store)
      container.register('eventstream:main', es)
      application.inject('route', 'eventStream', 'eventstream:main')
