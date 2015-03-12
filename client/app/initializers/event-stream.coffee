`import Ember from 'ember'`
`import EventStream from 'tahi/services/event-stream'`

EventStreamInitializer =
  name: 'eventStream'
  after: 'currentUser'
  initialize: (container, application) ->
    es = if !container.lookup('user:current') || Ember.testing
      Ember.Object.extend
        play: -> null
        pause: -> null
    else
      EventStream
    store = container.lookup('store:main')
    router = container.lookup('router:main')
    container.register('eventstream:main', es.extend({store: store, router: router}), singleton: true)
    application.inject('route', 'eventStream', 'eventstream:main')
    # TODO: shouldn't have to do this
    application.inject('service', 'eventStream', 'eventstream:main')

`export default EventStreamInitializer`
