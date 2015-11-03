`import Ember from 'ember'`
`import ENV from 'tahi/config/environment'`
`import AuthorizedRoute from 'tahi/routes/authorized'`

PaperVersionsRoute = AuthorizedRoute.extend({
  viewName: 'paper/versions',
  controllerName: 'paper/versions',
  templateName: 'paper/versions',
  cardOverlayService: Ember.inject.service('card-overlay'),
  restless: Ember.inject.service('restless'),
  fromSubmitOverlay: false,

  model: ->
    @modelFor('paper')

  afterModel: (model) ->
    return Ember.RSVP.all([
      model.get('tasks'),
      model.get('versionedTexts')])

  setupController: (controller, model) ->
    controller.set('model', model);
    controller.set('subRouteName', 'versions');
    console.log "ahllo", model
    controller.set('viewingVersion', model.get('versionedTexts').objectAt(0));
    if @currentUser
      this.get('restless').authorize(
        controller,
        "/api/papers/#{model.get('id')}/manuscript_manager",
        'canViewManuscriptManager'
      )

  actions:
    viewVersionedCard: (task, major_version, minor_version) ->
      @get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.versions', @modelFor('paper')],
        overlayBackground: 'paper.versions'
      })

      @transitionTo(
        'paper.task.version',
        @modelFor('paper'),
        task.id,
        major_version,
        minor_version)

    exitVersions: ->
      this.transitionTo('paper.index', this.modelFor('paper'));
})

`export default PaperVersionsRoute`
