ETahi.PaperIndexRoute = Ember.Route.extend
  redirect:(model) ->
    @transitionTo 'paper.edit', model
