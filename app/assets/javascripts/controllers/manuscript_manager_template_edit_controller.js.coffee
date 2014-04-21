ETahi.ManuscriptManagerTemplateEditController = Ember.ObjectController.extend

  paperTypes: (->
    @get('journal.paperTypes')
  ).property('journal.paperTypes.@each')

  sortedPhases: Ember.computed.alias 'template.phases'

  actions:
    changeTaskPhase: (task, targetPhase) ->

    addPhase: (position) ->
      newPhase = ETahi.TemplatePhase.create name: 'New Phase'
      @get('template.phases').insertAt(position, newPhase)

    removePhase: (phase) ->
      phaseArray = @get('template.phases')
      phaseArray.removeAt(phaseArray.indexOf(phase))

    addTask: (phase, taskName) ->
      newTask = ETahi.TemplateTask.create type: taskName, phase: phase
      phase.addTask(newTask)

    removeTask: (task) ->
      task.destroy()

    savePhase: (phase) ->

    rollbackPhase: (phase, oldName) ->
      phase.set('name', oldName)

