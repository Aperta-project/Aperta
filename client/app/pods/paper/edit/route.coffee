`import Ember from 'ember'`
`import AuthorizedRoute from 'tahi/routes/authorized'`
`import LazyLoader from 'tahi/mixins/routes/lazy-loader'`
`import RESTless from 'tahi/services/rest-less'`
`import Heartbeat from 'tahi/services/heartbeat'`
`import Utils from 'tahi/services/utils'`

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
    if @currentUser
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
    lockedBy and lockedBy == @currentUser

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

    showActivityFeed: ->
      paper = @modelFor('paper')
      controller = @controllerFor 'overlays/activityFeed'
      controller.set 'isLoading', true

      RESTless.get("/papers/#{paper.get('id')}/activity_feed").then (data) =>
        controller.setProperties
          isLoading: false
          model: Utils.deepCamelizeKeys(data.feeds)

      @render 'overlays/activityFeed',
        into: 'application',
        outlet: 'overlay',
        controller: controller

    addContributors: ->
      paper = @modelFor('paper')
      collaborations = paper.get('collaborations') || []
      controller = @controllerFor('overlays/showCollaborators')
      controller.setProperties
        paper: paper
        collaborations: collaborations
        initialCollaborations: collaborations.slice()
        allUsers: @store.find('user')

      @render('overlays/showCollaborators',
        into: 'application'
        outlet: 'overlay'
        controller: controller)

    showConfirmSubmitOverlay: ->
      @render 'overlays/paperSubmit',
        into: 'application',
        outlet: 'overlay',
        controller: 'overlays/paperSubmit'

    editableDidChange: ->
      @replaceWith('paper.index', @modelFor('paper'))

`export default PaperEditRoute`
