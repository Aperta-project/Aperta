ETahi.PaperIndexRoute = Ember.Route.extend
  actions:
    viewCard: (task) ->
      paper = @modelFor('paper')
      redirectParams = ['paper.index', @modelFor('paper')]
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/index')
      @transitionTo('paper.task', paper, task.id)
