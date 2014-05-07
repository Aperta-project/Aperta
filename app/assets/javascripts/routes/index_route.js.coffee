ETahi.IndexRoute = Ember.Route.extend
  model: ->
    if cachedModel =  @controllerFor('application').get('cachedModel')
      @controllerFor('application').set('cachedModel' , null)
      cachedModel
    else
      Ember.$.getJSON('/dashboard_info').then (data) =>
        @store.pushPayload('dashboard', data)
        @store.getById('dashboard', 1)

  afterModel: (model) ->
    model.set('allCardThumbnails', @store.all('cardThumbnail'))

  actions:
    viewCard: (task) ->
      redirectParams = ['index']
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('cachedModel' , @modelFor('index'))
      @controllerFor('application').set('overlayBackground', 'index')
      @transitionTo('task', task.get('litePaper.id'), task.get('id'))
