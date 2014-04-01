ETahi.FlowManagerRoute = Ember.Route.extend
  model: ->
    @store.find("flow")
