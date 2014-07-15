ETahi.ManuscriptManagerTemplateEditController = Ember.ObjectController.extend
  dirty: false
  errorText: ""

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

    addTask: (phase, taskType) ->
      unless Ember.isBlank(taskType)
        newTask = ETahi.TemplateTask.create type: taskType
        phase.addTask(newTask)
        @set('dirty', true)

    removeTask: (task) ->
      task.destroy()
      @set('dirty', true)

    savePhase: (phase) ->
      @set('dirty', true)

    rollbackPhase: (phase, oldName) ->
      phase.set('name', oldName)

    saveTemplate: (transition)->
      @get('model').save().then( (template) =>
        @set('dirty', false)
        @set('errorText', '')
        if transition
          transition.retry()
        else
          @transitionToRoute('manuscript_manager_template.edit', template)
      ).catch (errorResponse) =>
        if errorResponse.status == 422
          errors = _.values(errorResponse.responseJSON.errors).join(' ')
        else
          errors = "There was an error saving your changes. Please try again"
        Tahi.utils.togglePropertyAfterDelay(this, 'errorText', errors, '', 5000)

    rollback: ->
      @get('model').rollback()
      @set('dirty', false)
