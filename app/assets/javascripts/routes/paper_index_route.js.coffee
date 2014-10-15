ETahi.PaperIndexRoute = ETahi.AuthorizedRoute.extend
  afterModel: (model) ->
    @replaceWith('paper.edit', model) if model.get('editable')

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('commentLooks', @store.all('commentLook'))

  actions:
    viewCard: (task) ->
      paper = @modelFor('paper')
      redirectParams = ['paper.index', @modelFor('paper')]
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/index')
      @transitionTo('task', paper.id, task.id)

    editableDidChange: ->
      @replaceWith('paper.edit', @modelFor('paper'))
