ETahi.IndexRoute = Ember.Route.extend
  model: ->
    Ember.$.getJSON('/users/dashboard_info')

  actions:
    viewCard: (task) ->
      redirectParams = ['index']
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('overlayBackground', 'index')
      @transitionTo('paper.task', task.paper_id, task.id)
