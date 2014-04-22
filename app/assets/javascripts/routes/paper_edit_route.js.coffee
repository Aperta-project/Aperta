ETahi.PaperEditRoute = Ember.Route.extend
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

  actions:
    viewCard: (task) ->
      paper = @modelFor('paper')
      redirectParams = ['paper.edit', @modelFor('paper')]
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/edit')
      @transitionTo('task', paper.id, task.id)

    confirmSubmitPaper: ->
      @modelFor('paperEdit').save()
      @transitionTo('paper.submit')

    savePaper: ->
      @modelFor('paperEdit').save()
