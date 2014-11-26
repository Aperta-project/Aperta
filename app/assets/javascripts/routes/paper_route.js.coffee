ETahi.PaperRoute = Ember.Route.extend
  model: (params) ->
    if params.paper_id
      @store.find('paper', params.paper_id)
    else if params.publisher_prefix && params.suffix
      doi = params.publisher_prefix + '/' + params.suffix
      @store.find('paper', doi)

  afterModel: (paper, transition) ->
    if paper.id
      doi = paper.get("doi")
      if doi
        @transitionTo "paper.edit", doi
