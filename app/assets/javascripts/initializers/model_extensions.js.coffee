ETahi.initializer
  name: 'reopenDSModel'
  after: 'eventStream'
  initialize: ->
    DS.Model.reopen
      path: ->
        adapter = @get('store').adapterFor(this)
        resourceType = @constructor.typeKey
        resourceURL = adapter.buildURL(resourceType, @get('id'))

      # before performing a save pause the event stream
      adapterWillCommit: ->
        es = @container.lookup('eventstream:main')
        es.pause()
        @send('willCommit')
