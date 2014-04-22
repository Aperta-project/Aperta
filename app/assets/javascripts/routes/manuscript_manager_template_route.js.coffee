ETahi.ManuscriptManagerTemplateRoute = Ember.Route.extend
  model: (params) ->
    journal = @modelFor('journal')
    @set('paperTypes', journal.get('paperTypes'))
    types = new Ember.RSVP.Promise((resolve, reject) -> $.getJSON("/tasks/task_types", resolve).fail(reject))
    types.then (response) =>
      @set('taskTypes', response.task_types)
      @normalizeTemplateModels(journal.get('manuscriptManagerTemplates'))

  normalizeTemplateModels: (data) ->
    data.map (templateModel) ->
      ETahi.ManuscriptManagerTemplate.create(templateModel)

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('paperTypes', @get('paperTypes'))
    controller.set('taskTypes', @get('taskTypes'))
