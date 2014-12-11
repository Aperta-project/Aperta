EventStream =
  name: 'eventStream'
  after: 'currentUser'
  initialize: (container, application) ->
    if window.currentUserId
      store = container.lookup('store:main')
      es = if Ember.testing # fake event stream
        Ember.Object.extend
          play: -> null
          pause: -> null
      else
        ETahi.EventStream
      container.register('eventstream:main', es.extend({store: store}), singleton: true)
      application.inject('route', 'eventStream', 'eventstream:main')

`export default EventStream`
