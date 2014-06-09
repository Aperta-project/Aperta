ETahi.PaperEditRoute = ETahi.AdminAuthorizedRoute.extend
  beforeModel: ->
    visualEditorScript = '/visual-editor.js'
    unless ETahi.LazyLoaderMixin.loaded[visualEditorScript]
      $.getScript(visualEditorScript).then ->
        ETahi.LazyLoaderMixin.loaded[visualEditorScript] = true

  model: (params) ->
    paper = @modelFor('paper')
    new Ember.RSVP.Promise((resolve, reject) ->
      paper.get('tasks').then((tasks) -> resolve(paper)))

  afterModel: (model) ->
    @transitionTo('paper.index', model) if model.get('submitted')

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set 'authors', @store.all('author').filter (author) =>
      author.get('authorGroup.paper') == model

  actions:
    viewCard: (task) ->
      paper = @modelFor('paper')
      redirectParams = ['paper.edit', @modelFor('paper')]
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/edit')
      @transitionTo('task', paper.id, task.id)

    confirmSubmitPaper: ->
      return unless @modelFor('paperEdit').get('allMetadataTasksCompleted')
      @modelFor('paperEdit').save()
      @transitionTo('paper.submit')

    savePaper: ->
      return unless @modelFor('paperEdit').get('editable')
      @modelFor('paperEdit').save()
