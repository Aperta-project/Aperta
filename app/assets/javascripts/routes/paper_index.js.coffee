ETahi.PaperIndexRoute = Ember.Route.extend
  model: ->
    @modelFor('paper')
  redirect:(model) ->
    @transitionTo 'paper.edit', model
