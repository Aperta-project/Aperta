`import Ember from 'ember'`
`import ENV from 'tahi/config/environment'`
`import AuthorizedRoute from 'tahi/routes/authorized'`
`import loadVeEditorAssets from 'tahi-editor-ve/initializers/load-assets'`

PaperIndexRoute = AuthorizedRoute.extend
  viewName: 'paper/index'
  controllerName: 'paper/index'
  templateName: 'paper/index'
  cardOverlayService: Ember.inject.service('card-overlay'),
  heartbeatService: Ember.inject.service('heartbeat'),
  restless: Ember.inject.service('restless')
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
    return model.get('tasks')

  setupController: (controller, model) ->
    # paper/index controller is not used.
    # Controller is chosen based on Paper document type
    switch model.get('editorMode')
      when 'latex' then editorLookup = 'paper.index.latex-editor'
      when 'html' then editorLookup = 'paper.index.html-editor'
    @set('editorLookup', editorLookup)

    editorController = @controllerFor(@get('editorLookup'))
    editorController.set('model', model)
    editorController.set('commentLooks', @store.all('commentLook'))

    if @currentUser
      this.get('restless').authorize(editorController, "/api/papers/#{model.get('id')}/manuscript_manager", 'canViewManuscriptManager')

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
    @get('heartbeat')?.stop()

  isLockedByCurrentUser: ->
    lockedBy = @modelFor('paper').get('lockedBy')
    lockedBy and lockedBy == @currentUser

  actions:
    viewCard: (task) ->
      @get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.index', @modelFor('paper')],
        overlayBackground: @get('editorLookup')
      })

      @transitionTo('paper.task', @modelFor('paper'), task)

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

    # ask for confirmation while autosaving has not finished yet
    willTransition: (transition) ->
      editorController = @controllerFor(@get('editorLookup'))
      if editorController.get('isSaving') and not confirm("Are you sure you want to discard changes?")
        transition.abort()
        # In fact, when this is get's called, the URL has already been updated
        # so we do a history forward to actually preserve the URL.
        if window.history
          window.history.forward()
        false
      else
        true

`export default PaperIndexRoute`
