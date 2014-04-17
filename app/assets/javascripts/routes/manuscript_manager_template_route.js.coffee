ETahi.ManuscriptManagerTemplateRoute = Ember.Route.extend
  model: (params) ->
    journalId = @modelFor('journal').get('id')
    model = new Ember.RSVP.Promise((resolve, reject) -> $.getJSON("/manuscript_manager_templates?journal_id=#{journalId}", resolve).fail(reject))
    model.then(@normalizeTemplateModels)

  normalizeTemplateModels: (data) ->
    data.manuscript_manager_templates.map (templateModel) ->
      normalizedPhases = templateModel.get('template.phases').map (phase, index) ->
        tasks = phase.task_types.map (task) ->
          Ember.Object.create(title: task, isMessage: false)

        Ember.Object.create(name: phase.name, tasks: tasks, position: index + 1)

      templateModel.set('template.phases', normalizedPhases)
      templateModel

