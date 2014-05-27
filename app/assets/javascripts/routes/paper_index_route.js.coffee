ETahi.PaperIndexRoute = Ember.Route.extend
  afterModel: (model) ->
    @transitionTo('paper.edit', model) unless model.get('submitted')

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set 'authors', @store.all('author').filter (author) =>
      author.get('authorGroup.paper') == model

  actions:
    viewCard: (task) ->
      paper = @modelFor('paper')
      redirectParams = ['paper.index', @modelFor('paper')]
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/index')
      @transitionTo('task', paper.id, task.id)
