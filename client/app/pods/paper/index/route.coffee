`import AuthorizedRoute from 'tahi/routes/authorized'`
`import RESTless from 'tahi/services/rest-less'`

PaperIndexRoute = AuthorizedRoute.extend
  cardOverlayService: Ember.inject.service('card-overlay')

  afterModel: (model) ->
    @replaceWith('paper.edit', model) if model.get('editable')

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('commentLooks', @store.all('commentLook'))
    if @currentUser
      RESTless.authorize(controller, "/api/papers/#{model.get('id')}/manuscript_manager", 'canViewManuscriptManager')

  actions:
    viewCard: (task) ->
      @get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.index', @modelFor('paper')],
        overlayBackground: 'paper/index'
      })

      @transitionTo('paper.task', @modelFor('paper'), task.id)

    editableDidChange: ->
      @replaceWith('paper.edit', @modelFor('paper'))

`export default PaperIndexRoute`
