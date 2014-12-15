`import Ember from 'ember'`
`import EventStream from 'tahi/services/event-stream'`

EventStreamInitializer =
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
        EventStream
      container.register('eventstream:main', es.extend({store: store}), singleton: true)
      application.inject('route', 'eventStream', 'eventstream:main')

`export default EventStreamInitializer`
