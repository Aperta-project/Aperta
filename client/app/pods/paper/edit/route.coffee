`import Ember from 'ember'`
`import AuthorizedRoute from 'tahi/routes/authorized'`
`import LazyLoader from 'tahi/mixins/routes/lazy-loader'`
`import RESTless from 'tahi/services/rest-less'`
`import Heartbeat from 'tahi/services/heartbeat'`

PaperEditRoute = AuthorizedRoute.extend
  heartbeatService: null

  beforeModel: ->
    visualEditorScript = '/visualEditor.min.js'
    unless LazyLoader.loaded[visualEditorScript]
      $.getScript(visualEditorScript).then ->
        LazyLoader.loaded[visualEditorScript] = true

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
    if @getCurrentUser? && @getCurrentUser()
      RESTless.authorize(controller, "/papers/#{model.get('id')}/manuscript_manager", 'canViewManuscriptManager')

  deactivate: ->
    @endHeartbeat()

  startHeartbeat: ->
    if @isLockedByCurrentUser()
      @get('heartbeatService').start()

  endHeartbeat: ->
    @get('heartbeatService').stop()

  isLockedByCurrentUser: ->
    lockedBy = @modelFor('paper').get('lockedBy')
    lockedBy and lockedBy == @getCurrentUser()

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

    addContributors: ->
      paper = @modelFor('paper')
      collaborations = paper.get('collaborations') || []
      controller = @controllerFor('showCollaboratorsOverlay')
      controller.setProperties
        paper: paper
        collaborations: collaborations
        initialCollaborations: collaborations.slice()
        allUsers: @store.find('user')
      @render('showCollaboratorsOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'showCollaboratorsOverlay')

    showConfirmSubmitOverlay: ->
      @render 'paperSubmitOverlay',
        into: 'application',
        outlet: 'overlay',
        controller: 'paperSubmitOverlay'

    editableDidChange: ->
      @replaceWith('paper.index', @modelFor('paper'))

`export default PaperEditRoute`
