ETahi.ManuscriptManagerTemplateEditController = Ember.ObjectController.extend
  paperTypes: (->
    @get('journal.paperTypes')
  ).property('journal.paperTypes.@each')

  sortedPhases: Ember.computed.alias 'phases'

  actions:
    changeTaskPhase: (task, targetPhase) ->
      task.get('phase').removeTask(task)
      targetPhase.addTask(task)

    addPhase: (position) ->
      newPhase = ETahi.TemplatePhase.create name: 'New Phase'
      @get('phases').insertAt(position, newPhase)

    removePhase: (phase) ->
      phaseArray = @get('phases')
      phaseArray.removeAt(phaseArray.indexOf(phase))

    addTask: (phase, taskName) ->
      newTask = ETahi.TemplateTask.create type: taskName
      phase.addTask(newTask)

    removeTask: (task) ->
      task.destroy()

    savePhase: (phase) ->

    rollbackPhase: (phase, oldName) ->
      phase.set('name', oldName)

    saveTemplate: ->
      @get('model').save()

    rollbackTemplate: ->
      @get('model').rollback()
