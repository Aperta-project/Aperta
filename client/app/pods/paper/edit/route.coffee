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

  beforeModel: ->
    initializeVisualEditor(ENV).catch( (err) ->
      Ember.Logger.error(err) )

  model: ->
    paper = @modelFor('paper')
    new Ember.RSVP.Promise((resolve, reject) ->
      paper.get('tasks').then((tasks) -> resolve(paper)))

  afterModel: (model) ->
    if model.get('editable')
      @set('heartbeatService', Heartbeat.create(resource: model))
      @startHeartbeat()
    else
      @replaceWith('paper.index', model)

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('commentLooks', @store.all('commentLook'))
    if @currentUser
      RESTless.authorize(controller, "/api/papers/#{model.get('id')}/manuscript_manager", 'canViewManuscriptManager')

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
    controller = @controllerFor('paper.edit')
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
      redirectParams = ['paper.edit', @modelFor('paper')]
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/edit')
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
      controller = @controllerFor('paper.edit')
      editor = controller.get('editor')
      editor.freeze();
      # do not handle model changes while overlay is open
      controller.disconnectEditor()
      controller.set('hasOverlay', true)
      @render 'paper/edit/figures',
        into: 'application'
        outlet: 'overlay'
        controller: 'paper/edit/figures'
        model: @modelFor('paper.edit')

    openTables: ->
      # TODO

    insertFigure: (figureId) ->
      editor = @controllerFor('paper.edit').get('editor')
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
