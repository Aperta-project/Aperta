`import Ember from 'ember'`
`import RESTless from 'tahi/services/rest-less'`
`import Heartbeat from 'tahi/services/heartbeat'`
`import ENV from 'tahi/config/environment'`
`import AuthorizedRoute from 'tahi/routes/authorized'`
`import loadVeEditorAssets from 'tahi-editor-ve/initializers/load-assets'`

PaperEditRoute = AuthorizedRoute.extend
  fromSubmitOverlay: false

  heartbeatService: null

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
      @set('heartbeatService', Heartbeat.create(resource: model))
      @startHeartbeat()
    else
      @transitionTo('paper.index', model)

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
      RESTless.authorize(editorController, "/api/papers/#{model.get('id')}/manuscript_manager", 'canViewManuscriptManager')

  renderTemplate: (paperEditController, model) ->
    @render @get('editorLookup'),
      into: 'application'
      view: @get('editorLookup')
      controller: @get('editorLookup')

  deactivate: ->
    @endHeartbeat()

  startHeartbeat: ->
    if @isLockedByCurrentUser()
      @get('heartbeatService').start()

  endHeartbeat: ->
    @get('heartbeatService').stop()

  isLockedByCurrentUser: ->
    lockedBy = @modelFor('paper').get('lockedBy')
    lockedBy and lockedBy == @currentUser

  actions:
    viewCard: (task) ->
      paper = @modelFor('paper')
      redirectParams = ['paper.edit', paper]
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('overlayBackground', @get('editorLookup'))
      @transitionTo('paper.task', paper, task.id)

    startEditing: ->
      @startHeartbeat()

    stopEditing: ->
      @endHeartbeat()

    showConfirmSubmitOverlay: ->
      @render 'overlays/paperSubmit',
        into: 'application',
        outlet: 'overlay',
        controller: 'overlays/paperSubmit'
      @set 'fromSubmitOverlay', true

    editableDidChange: ->
      if !@fromSubmitOverlay
        @transitionTo('paper.index', @modelFor('paper'))
      else
        @set 'fromSubmitOverlay', false

`export default PaperEditRoute`
