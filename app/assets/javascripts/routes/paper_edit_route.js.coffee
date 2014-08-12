ETahi.PaperEditRoute = ETahi.AuthorizedRoute.extend
  heartbeatService: null

  beforeModel: ->
    visualEditorScript = '/visualEditor.min.js'
    unless ETahi.LazyLoaderMixin.loaded[visualEditorScript]
      $.getScript(visualEditorScript).then ->
        ETahi.LazyLoaderMixin.loaded[visualEditorScript] = true

  model: ->
    paper = @modelFor('paper')
    new Ember.RSVP.Promise((resolve, reject) ->
      paper.get('tasks').then((tasks) -> resolve(paper)))

  afterModel: (model) ->
    if model.get('submitted')
      @replaceWith('paper.index', model) 
    else
      @set('heartbeatService', ETahi.HeartbeatService.create(resource: model))
      @startHeartbeat()

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set 'authors', @store.all('author').filter (author) =>
      model.get('authorGroups').indexOf(author.get('authorGroup')) > -1

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

    addCollaborators: ->
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
