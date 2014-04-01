ETahi.IndexRoute = Ember.Route.extend
  model: ->
    Ember.$.getJSON('/users/dashboard_info')

  actions:
    viewCard: (task) ->
      @transitionTo('task', task.id)
