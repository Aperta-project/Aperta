ETahi.AdminRoute = ETahi.AuthorizedRoute.extend
  model: ->
    @store.find('adminJournal')
