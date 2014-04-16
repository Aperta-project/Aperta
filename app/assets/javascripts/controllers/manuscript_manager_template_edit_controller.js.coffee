ETahi.ManuscriptManagerTemplateEditController = Ember.ObjectController.extend

  sortedPhases: ( ->
    @get('template.phases').map (phase) ->
      tasks = phase.task_types.map (task) ->
        Ember.Object.create(title: task, isMessage: false)

      Ember.Object.create(tasks: tasks, name: phase.name)
  ).property('template.phases')
  updatePositions: (phase)->
    relevantPhases = @get('model.phases').filter((p)->
      p != phase && p.get('position') >= phase.get('position')
    )

    relevantPhases.invoke('incrementProperty', 'position')

  changeTaskPhase: (task, targetPhase) ->
    task.set('phase', targetPhase)
    task.save()

  actions:
    addPhase: (position) ->

    removePhase: (phase) ->

    removeTask: (task) ->
