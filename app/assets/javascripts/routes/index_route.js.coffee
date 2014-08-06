ETahi.IndexRoute = Ember.Route.extend
  model: ->
    @store.find 'dashboard'
    .then (dashboardArray) -> dashboardArray.get 'firstObject'

  actions:
    didTransition: () ->
      @controllerFor('index').set 'pageNumber', 1
