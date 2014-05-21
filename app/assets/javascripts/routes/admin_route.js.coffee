ETahi.AdminRoute = ETahi.AdminAuthorizedRoute.extend
  model: ->
    @store.find('journal')
