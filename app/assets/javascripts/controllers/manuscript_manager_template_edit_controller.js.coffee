ETahi.ManuscriptManagerTemplateEditController = Ember.ObjectController.extend
  dirty: false
  errorText: ""
  editMode: false

  canRemoveCard: true
  sortedPhases: Ember.computed.alias 'phaseTemplates'

  showSaveButton: (->
    @get('dirty') || @get('editMode')
  ).property('dirty', 'editMode')

  actions:
    toggleEditMode: ->
      console.log("toggleEditMode")
      @toggleProperty 'editMode'
      return null

    cancelEditMode: ->
      console.log("cancelEditMode")
      @send('rollback')

    changeTaskPhase: (task, targetPhase) ->
      console.log("changeTaskPhase")
      task.get('phase').removeTask(task)
      targetPhase.addTask(task)
      @set('dirty', true)

    addPhase: (position) ->
      console.log("addPhase at position: " + position)
      @get('model.phaseTemplates').forEach (phaseTemplate) ->
        if phaseTemplate.get('position') >= position
          phaseTemplate.incrementProperty('position')

      @store.createRecord 'phaseTemplate',
        name: 'New Phase'
        manuscriptManagerTemplate: @get('model')
        position: position

      @set('dirty', true)

    removePhase: (phaseTemplate) ->
      console.log("WORKS! removePhase")
      phaseTemplate.deleteRecord()
      @set('dirty', true)

    addTask: (phaseTemplate, journalTaskType) ->
      console.log("WORKS! addTask")
      unless Ember.isBlank(journalTaskType)
        newTask = @store.createRecord 'taskTemplate', journalTaskType: journalTaskType, phaseTemplate: phaseTemplate, title: journalTaskType.get('title')
        @set('dirty', true)

    removeTask: (taskTemplate) ->
      console.log("WORKS! removeTask")
      taskTemplate.deleteRecord()
      @set('dirty', true)

    savePhase: (phase) ->
      console.log("WORKS! savePhase")
      @set('dirty', true)

    rollbackPhase: (phase, oldName) ->
      console.log("WORKS! rollbackPhase")
      phase.set('name', oldName)

    saveTemplate: (transition)->
      console.log("saveTemplate")
      @set 'editMode', false
      @set('dirty', false)

      @get('model').save().then( (mmt) =>
        taskTemplates = []

        phasePromises = mmt.get('phaseTemplates').invoke('save')
        Em.RSVP.all(phasePromises).then (phaseTemplates) =>
          promises = phaseTemplates.map (phaseTemplate) ->
            phaseTemplate.get('taskTemplates').invoke('save')

          Em.RSVP.all(promises.compact()).then =>
            @set('errorText', '')
            if transition
              transition.retry()
            else
              @transitionToRoute('manuscript_manager_template.edit', mmt)

      ).catch (errorResponse) =>
        if errorResponse.status == 422
          errors = _.values(errorResponse.responseJSON.errors).join(' ')
        else
          errors = "There was an error saving your changes. Please try again"
        Tahi.utils.togglePropertyAfterDelay(this, 'errorText', errors, '', 5000)

    rollback: ->
      console.log("rollback")
      mmt = @get('model')
      mmt.get('phaseTemplates').forEach (phaseTemplate) ->
        phaseTemplate.get('taskTemplates').forEach (taskTemplate) ->
          taskTemplate.rollback()
        phaseTemplate.rollback()
      mmt.rollback()
      @set('dirty', false)
      @send('didRollBack')
