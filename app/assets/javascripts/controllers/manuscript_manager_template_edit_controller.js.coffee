ETahi.ManuscriptManagerTemplateEditController = Ember.ObjectController.extend

  paperTypes: (->
    @get('journal.paperTypes')
  ).property('journal.paperTypes.@each')

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


  actions:
    changeTaskPhase: (task, targetPhase) ->

    addPhase: (position) ->

    removePhase: (phase) ->

    removeTask: (task) ->

    savePhase: (phase) ->

    rollbackPhase: (phase) ->


