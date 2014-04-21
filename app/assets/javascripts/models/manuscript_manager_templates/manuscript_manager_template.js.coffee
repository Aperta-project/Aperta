ETahi.ManuscriptManagerTemplate = Ember.Object.extend
  init:  ->
    normalizedPhases = @get('template').phases.map (phase) ->
      newPhase = ETahi.TemplatePhase.create(name: phase.name)
      tasks = phase.task_types.map (task) ->
        ETahi.TemplateTask.create(type: task, phase: newPhase)
      newPhase.set('tasks', tasks)
      newPhase
    @setProperties
      paperType: @get('paper_type')
      phases: normalizedPhases
      template: null

  templateJSON: ( ->
    serializedPhases = @get('phases').map (phase) ->
      task_types = phase.get('tasks').map (task) ->
        task.get('type')
      phase =
        name: phase.get('name')
        task_types: task_types

    payload =
      id: @get('id')
      paper_type: @get('paperType')
      name: @get('name')
      template:
        phases: serializedPhases
  ).property().volatile()

