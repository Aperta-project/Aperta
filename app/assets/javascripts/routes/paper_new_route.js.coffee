ETahi.PaperNewRoute = Ember.Route.extend
  model: (params) ->
    @store.find('journal').then (journals) =>
      @set('journals', journals)
      @store.createRecord 'paper',
        journal: journals.get('content.firstObject')
        paperType: journals.get('content.firstObject.paperTypes.firstObject')

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('journals', @get('journals'))
