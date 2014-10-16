ETahi.AdminIndexRoute = ETahi.AuthorizedRoute.extend
  setupController: (controller) ->
    controller.set('promise', @store.find('adminJournal'))
