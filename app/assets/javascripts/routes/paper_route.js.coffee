ETahi.PaperRoute = Ember.Route.extend
  model: (params) ->
    @store.find('paper', params.paper_id)

  actions:
    viewCard: (task) ->
      @transitionTo('paper.task', task)
