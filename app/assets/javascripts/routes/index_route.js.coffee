ETahi.IndexRoute = Ember.Route.extend
  model: ->
    if cachedModel = @controllerFor('application').get('cachedModel')
      @controllerFor('application').set('cachedModel', null)
      cachedModel
    else
      @store.find('dashboard', page_number: 1).then (dashboardArray) -> dashboardArray.get 'firstObject'

  afterModel: (model) ->
    model.set('allCardThumbnails', @store.all('cardThumbnail'))

  actions:
    viewCard: (task) ->
      redirectParams = ['index']
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('cachedModel' , @modelFor('index'))
      @controllerFor('application').set('overlayBackground', 'index')
      @transitionTo('task', task.get('litePaper.id'), task.get('id'))
