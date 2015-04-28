`import Ember from 'ember'`
`import AuthorizedRoute from 'tahi/routes/authorized'`
`import LazyLoader from 'tahi/mixins/routes/lazy-loader'`
`import RESTless from 'tahi/services/rest-less'`
`import Heartbeat from 'tahi/services/heartbeat'`
`import ENV from 'tahi/config/environment'`
`import initializeVisualEditor from 'ember-cli-visualeditor/initializers/initialize_visual_editor'`

PaperEditRoute = AuthorizedRoute.extend
  fromSubmitOverlay: false

  heartbeatService: null

  model: ->
    paper = @modelFor('paper')

    # if paper.get('editorMode') is 'html'
    #   veInit = initializeVisualEditor(ENV).catch((error) ->
    #     Ember.Logger.error(error))
    # else
    #   veInit = Ember.RSVP.Promise.resolve()

    veInit = initializeVisualEditor(ENV).catch((error) ->
      Ember.Logger.error(error))

    taskLoad = new Ember.RSVP.Promise((resolve, reject) ->
      paper.get('tasks').then((tasks) -> resolve(paper)))

    Ember.RSVP.all([veInit, taskLoad]).then ->
      paper

  afterModel: (model) ->
    if model.get('editable')
      @set('heartbeatService', Heartbeat.create(resource: model))
      @startHeartbeat()
    else
      @replaceWith('paper.index', model)

  setupController: (controller, model) ->
    # paper/edit controller is not used.
    # Controller is chosen based on Paper document type
    # @set('editorLookup', 'paper.edit.' + model.get('editorMode') + '-editor')
    @set('editorLookup', 'paper.edit.' + 'html' + '-editor')
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

  closeOverlay: ->
    controller = @controllerFor(@get('editorLookup'))
    editor = controller.get('editor')

    @disconnectOutlet
      outlet: 'overlay'
      parentView: 'application'
    controller.set('hasOverlay', false)
    controller.connectEditor()
    editor.unfreeze()

  actions:
    viewCard: (task) ->
      paper = @modelFor('paper')
      redirectParams = ['paper.edit', paper]
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('overlayBackground', @get('editorLookup'))
      @transitionTo('task', paper.id, task.id)

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
        @replaceWith('paper.index', @modelFor('paper'))
      else
        @set 'fromSubmitOverlay', false

    openFigures: ->
      controller = @controllerFor(@get('editorLookup'))
      editor = controller.get('editor')
      editor.freeze()
      # do not handle model changes while overlay is open
      controller.disconnectEditor()
      controller.set('hasOverlay', true)

      figureController = @controllerFor('paper/edit/figures')
      figureController.set('manuscriptEditor', controller.get('editor'))

      @render 'paper/edit/figures',
        into: 'application'
        outlet: 'overlay'
        controller: figureController
        model: @modelFor('paper.edit')

    openTables: ->
      # TODO

    insertFigure: (figureId) ->
      editor = @controllerFor(@get('editorLookup')).get('editor')
      # NOTE: we need to provide the full HTML representation right away
      @closeOverlay()
      figure = @modelFor('paper.edit').get('figures').findBy('id', figureId)
      if figure
        editor.getSurfaceView().execute('figure', 'insert', figure.toHtml())
      else
        console.error('No figure with id', figureId)

    closeOverlay: ->
      @closeOverlay()

    destroyAttachment: (attachment) ->
      @modelFor('paper').get('figures').removeObject(attachment)
      attachment.destroyRecord()

`export default PaperEditRoute`
