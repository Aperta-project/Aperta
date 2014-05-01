ETahi.IndexRoute = Ember.Route.extend
  beforeModel: ->
    store = @store
    Ember.$.getJSON('/dashboard_info').then (data)->
      store.pushPayload('dashboard', data)

  model: ->
    @store.all('dashboard').get('firstObject')

  afterModel: (model) ->
    model.set('allCardThumbnails', @store.all('cardThumbnail'))

  actions:
    viewCard: (task) ->
      redirectParams = ['index']
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('overlayBackground', 'index')
      @transitionTo('task', task.get('litePaper.id'), task.get('id'))
