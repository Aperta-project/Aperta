ETahi.ManuscriptManagerTemplateEditRoute = Ember.Route.extend ETahi.AlertUnsavedChanges,
  model: (params) ->
    @store.find('manuscriptManagerTemplate', parseInt(params.template_id))

  afterModel: (model) ->
    model.reload() unless model.get('phaseTemplates.length')

  actions:
    saveChanges: ->
      @controller.send('saveTemplate', @get('attemptingTransition'))

    didRollBack: ->
      # nothing to do here
