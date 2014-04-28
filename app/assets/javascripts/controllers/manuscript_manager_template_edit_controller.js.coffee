ETahi.ManuscriptManagerTemplateEditController = Ember.ObjectController.extend
  dirty: false

  paperTypes: (->
    @get('journal.paperTypes')
  ).property('journal.paperTypes.@each')

  sortedPhases: Ember.computed.alias 'phases'

  actions:
    changeTaskPhase: (task, targetPhase) ->
      task.get('phase').removeTask(task)
      targetPhase.addTask(task)
      @set('dirty', true)

    addPhase: (position) ->
      newPhase = ETahi.TemplatePhase.create name: 'New Phase'
      @get('phases').insertAt(position, newPhase)
      @set('dirty', true)

    removePhase: (phase) ->
      phaseArray = @get('phases')
      phaseArray.removeAt(phaseArray.indexOf(phase))
      @set('dirty', true)

    addTask: (phase, taskName) ->
      unless Ember.isBlank(taskName)
        newTask = ETahi.TemplateTask.create type: taskName
        phase.addTask(newTask)
        @set('dirty', true)

    removeTask: (task) ->
      task.destroy()
      @set('dirty', true)

    savePhase: (phase) ->
      @set('dirty', true)

    rollbackPhase: (phase, oldName) ->
      phase.set('name', oldName)

    saveTemplate: ->
      @get('model').save().then (template) =>
        @set('dirty', false)
        @transitionToRoute('manuscript_manager_template.edit', template)

    rollbackTemplate: ->
      @get('model').rollback()
      @set('dirty', false)
