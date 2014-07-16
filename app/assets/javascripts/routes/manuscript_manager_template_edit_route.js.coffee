ETahi.ManuscriptManagerTemplateEditRoute = Ember.Route.extend(ETahi.AlertUnsavedChanges,
  model: (params) ->
    @modelFor('journal')
      .get('manuscriptManagerTemplates')
      .findBy('id', parseInt(params.template_id))

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('journal', @modelFor('journal'))

  actions:
    saveChanges: ->
      @controller.send('saveTemplate', @get('attemptingTransition'))
)
