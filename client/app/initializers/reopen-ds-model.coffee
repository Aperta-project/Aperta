ReopenDSModel =
  name: 'reopenDSModel'
  after: 'eventStream'
  initialize: (container, application) ->
    DS.Model.reopen
      path: ->
        adapter = @get('store').adapterFor(this)
        resourceType = @constructor.typeKey
        resourceURL = adapter.buildURL(resourceType, @get('id'))

      # before performing a save pause the event stream
      adapterWillCommit: ->
        es = container.lookup('eventstream:main')
        # es.pause()
        @send('willCommit')

`export default ReopenDSModel`
