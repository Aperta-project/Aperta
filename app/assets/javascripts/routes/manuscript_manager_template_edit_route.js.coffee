ETahi.ManuscriptManagerTemplateEditRoute = Ember.Route.extend(ETahi.AlertUnsavedChanges,
  model: (params) ->
    @modelFor('journal')
      .get('manuscriptManagerTemplates')
      .findBy('id', parseInt(params.template_id))

  afterModel: ->
    @set('location', window.location.pathname)

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('journal', @modelFor('journal'))

)
