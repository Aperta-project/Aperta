ETahi.ManuscriptManagerTemplateRoute = ETahi.AdminAuthorizedRoute.extend
  model: (params) ->
    journal = @modelFor('journal')
    types = new Ember.RSVP.Promise((resolve, reject) -> $.getJSON("/tasks/task_types", resolve).fail(reject))
    types.then (response) =>
      @set('taskTypes', response.task_types)
      @normalizeTemplateModels(journal.get('manuscriptManagerTemplates'))

  normalizeTemplateModels: (data) ->
    data.map (templateModel) ->
      ETahi.ManuscriptManagerTemplate.create(templateModel)

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('taskTypes', @get('taskTypes'))
