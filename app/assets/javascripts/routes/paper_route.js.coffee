ETahi.PaperRoute = Ember.Route.extend
  model: (params) ->
    @store.find('paper', params.paper_id)

  afterModel: (model) ->
    transitionRoute = if model.get('submitted') then 'paper.index' else 'paper.edit'
    @transitionTo(transitionRoute, model)
