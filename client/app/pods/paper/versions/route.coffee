`import Ember from 'ember'`
`import ENV from 'tahi/config/environment'`
`import AuthorizedRoute from 'tahi/routes/authorized'`

PaperVersionsRoute = AuthorizedRoute.extend
  viewName: 'paper/versions'
  controllerName: 'paper/versions'
  templateName: 'paper/versions'
  cardOverlayService: Ember.inject.service('card-overlay'),
  restless: Ember.inject.service('restless')
  fromSubmitOverlay: false

  model: ->
    paper = @modelFor('paper')

  afterModel: (model) ->
    return model.get('tasks')

  setupController: (controller, model) ->
    controller.set('model', model);
    if @currentUser
      this.get('restless').authorize(
        controller,
        "/api/papers/#{model.get('id')}/manuscript_manager",
        'canViewManuscriptManager'
      )

  actions:
    viewCard: (task) ->
      @get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.versions', @modelFor('paper')],
        overlayBackground: 'paper.versions'
      })

      @transitionTo('paper.task.version', @modelFor('paper'), task.id, 0, 0)

`export default PaperVersionsRoute`
