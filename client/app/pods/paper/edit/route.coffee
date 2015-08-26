`import Ember from 'ember'`
`import ENV from 'tahi/config/environment'`
`import AuthorizedRoute from 'tahi/routes/authorized'`
`import loadVeEditorAssets from 'tahi-editor-ve/initializers/load-assets'`

PaperEditRoute = AuthorizedRoute.extend
  restless: Ember.inject.service('restless')
  heartbeatService: Ember.inject.service('heartbeat')
  cardOverlayService: Ember.inject.service('card-overlay')

  viewName: 'paper/edit'
  controllerName: 'paper/edit'
  templateName: 'paper/edit'
  cardOverlayService: Ember.inject.service('card-overlay'),
  fromSubmitOverlay: false

  fromSubmitOverlay: false

  model: ->
    paper = @modelFor('paper')
    editorInit = Ember.RSVP.Promise.resolve()

    if paper.get('editorMode') is 'html' and not Ember.testing
      editorInit = loadVeEditorAssets(ENV).catch((error) ->
        Ember.Logger.error(error))

    taskLoad = new Ember.RSVP.Promise((resolve, reject) ->
      paper.get('tasks').then((tasks) -> resolve(paper)))

    Ember.RSVP.all([editorInit, taskLoad]).then ->
      paper

  afterModel: (model) ->
    if model.get('editable')
      @set('heartbeat', this.get('heartbeatService').create(model))
      @startHeartbeat()

  setupController: (controller, model) ->
    # paper/edit controller is not used.
    # Controller is chosen based on Paper document type
    switch model.get('editorMode')
      when 'latex' then editorLookup = 'paper.edit.latex-editor'
      when 'html' then editorLookup = 'paper.edit.html-editor'
    @set('editorLookup', editorLookup)

    editorController = @controllerFor(@get('editorLookup'))
    editorController.set('model', model)
    editorController.set('commentLooks', @store.all('commentLook'))

    if @currentUser
      @get('restless').authorize(editorController, "/api/papers/#{model.get('id')}/manuscript_manager", 'canViewManuscriptManager')

  renderTemplate: (paperEditController, model) ->
    @render @get('editorLookup'),
      into: 'application'
      view: @get('editorLookup')
      controller: @get('editorLookup')

  deactivate: ->
    @endHeartbeat()

  startHeartbeat: ->
    if @isLockedByCurrentUser()
      @get('heartbeat').start()

  endHeartbeat: ->
    @get('heartbeatService')?.stop()

  isLockedByCurrentUser: ->
    lockedBy = @modelFor('paper').get('lockedBy')
    lockedBy and lockedBy == @currentUser

  actions:
    viewCard: (task) ->
      @get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.edit', @modelFor('paper')],
        overlayBackground: @get('editorLookup')
      })

      @transitionTo('paper.task', @modelFor('paper'), task.id)

    startEditing: ->
      @startHeartbeat()

    stopEditing: ->
      @endHeartbeat()

    showConfirmSubmitOverlay: ->
      @controllerFor('overlays/paper-submit').set('model', this.modelFor('paper'))

      @send('openOverlay', {
        template: 'overlays/paper-submit'
        controller: 'overlays/paper-submit'
      })

      @set 'fromSubmitOverlay', true

`export default PaperEditRoute`
