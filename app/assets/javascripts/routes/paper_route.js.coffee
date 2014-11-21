ETahi.PaperRoute = Ember.Route.extend
  model: (params) ->
    if params.publisher_prefix && params.suffix
      doi = params.publisher_prefix + '/' + params.suffix
      console.log('PaperRoute.model', doi)
      # does a GET to e.g. /papers?doi=publisher%2Fjournal.2
      return @store.find('paper', { doi: doi })

    console.log('normal', params)
    @store.find('paper', params.paper_id)
