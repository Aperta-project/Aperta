ETahi.initializer
  name: 'coalesceFinds'
  initialize: ->
    DS.RESTAdapter.reopen
      coalesceFindRequests: true
