ETahi.initializer
  name: 'reopenDSModel'

  initialize: (container, application) ->
    DS.Model.reopen
      path: ->
        adapter = @get('store').adapterFor(this)
        resourceType = @constructor.typeKey
        resourceURL = adapter.buildURL(resourceType, @get('id'))
