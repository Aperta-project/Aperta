ETahi.PaperEditRoute = Ember.Route.extend
  model: ->
    @modelFor('paper')
  actions:
    viewCard: (task) ->
      paper = @modelFor('paper')
      redirectParams = ['paper.edit', @modelFor('paper')]
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/edit')
      @transitionTo('paper.task', paper, task.id)
