ETahi.ManuscriptManagerTemplateEditRoute = Ember.Route.extend
  model: (params) ->
    @modelFor('manuscriptManagerTemplate')
      .findBy('id', parseInt(params.template_id))

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('journal', @modelFor('journal'))
