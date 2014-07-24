ETahi.PaperEditRoute = ETahi.AuthorizedRoute.extend
  beforeModel: ->
    visualEditorScript = '/visual-editor.js'
    unless ETahi.LazyLoaderMixin.loaded[visualEditorScript]
      $.getScript(visualEditorScript).then ->
        ETahi.LazyLoaderMixin.loaded[visualEditorScript] = true

  model: ->
    paper = @modelFor('paper')
    new Ember.RSVP.Promise((resolve, reject) ->
      paper.get('tasks').then((tasks) -> resolve(paper)))

  afterModel: (model) ->
    @replaceWith('paper.index', model) if model.get('submitted')

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set 'authors', @store.all('author').filter (author) =>
      model.get('authorGroups').indexOf(author.get('authorGroup')) > -1

  actions:
    viewCard: (task) ->
      paper = @modelFor('paper')
      redirectParams = ['paper.edit', @modelFor('paper')]
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/edit')
      @transitionTo('task', paper.id, task.id)

    addCollaborators: ->
      paper = @modelFor('paper')
      collaborations = paper.get('collaborations') || []
      controller = @controllerFor('showCollaboratorsOverlay')
      controller.setProperties
        paper: paper
        collaborations: collaborations
        initialCollaborations: collaborations.map (collab) -> collab
        allUsers: @store.find('user')
      @render('showCollaboratorsOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'showCollaboratorsOverlay')
