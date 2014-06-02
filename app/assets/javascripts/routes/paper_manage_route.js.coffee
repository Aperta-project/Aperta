ETahi.PaperManageRoute = Ember.Route.extend
  actions:
    viewCard: (task) ->
      paper = @modelFor('paper')
      redirectParams = ['paper.manage', @modelFor('paper')]
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/manage')
      @transitionTo('task', paper.id, task.id)
