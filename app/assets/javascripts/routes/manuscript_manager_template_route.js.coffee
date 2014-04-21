ETahi.ManuscriptManagerTemplateRoute = Ember.Route.extend
  model: (params) ->
    journalId = @modelFor('journal').get('id')
    templates = new Ember.RSVP.Promise((resolve, reject) -> $.getJSON("/manuscript_manager_templates?journal_id=#{journalId}", resolve).fail(reject))
    taskTypes = new Ember.RSVP.Promise((resolve, reject) -> $.getJSON("/tasks/task_types", resolve).fail(reject))
    model = Ember.RSVP.all([templates, taskTypes])
    model.then (responses) =>
      @set('taskTypes', responses[1].task_types)
      @normalizeTemplateModels(responses[0])

  normalizeTemplateModels: (data) ->
    data.manuscript_manager_templates.map (templateModel) ->
      templateModel = Ember.Object.create(templateModel)
      normalizedPhases = templateModel.get('template.phases').map (phase) ->
        newPhase = ETahi.TemplatePhase.create(name: phase.name)
        tasks = phase.task_types.map (task) ->
          ETahi.TemplateTask.create(type: task, phase: newPhase)
        newPhase.set('tasks', tasks)
        newPhase

      templateModel.set('template.phases', normalizedPhases)
      templateModel

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('taskTypes', @get('taskTypes'))

