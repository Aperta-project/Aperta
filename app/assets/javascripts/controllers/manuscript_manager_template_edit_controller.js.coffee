ETahi.ManuscriptManagerTemplateEditController = Ember.ObjectController.extend
  dirty: false
  errorText: ""
  editMode: false
  journal: Em.computed.alias('model.journal')

  sortedPhases: Ember.computed.alias 'phaseTemplates'
  removedTasks: null

  initArrays: (->
    @set('removedTasks', [])
  ).on('init')

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

    changeTaskPhase: (taskTemplate, targetPhaseTemplate) ->
      console.log("WORKS! changeTaskPhase")
      newPosition = targetPhaseTemplate.get('length')
      taskTemplate.setProperties
        phaseTemplate: targetPhaseTemplate
        position: newPosition
      taskTemplate.send('becomeDirty')
      targetPhaseTemplate.get('taskTemplates').pushObject(taskTemplate)
      @set('dirty', true)

    addPhase: (position) ->
      console.log("WORKS! addPhase at position: " + position)
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
      @get('removedTasks').pushObject(taskTemplate)
      taskTemplate.deleteRecord()
      @set('dirty', true)

    savePhase: (phase) ->
      console.log("WORKS! savePhase")
      @set('dirty', true)

    rollbackPhase: (phase, oldName) ->
      console.log("WORKS! rollbackPhase")
      phase.set('name', oldName)

    saveTemplate: (transition)->
      console.log("WORKS! saveTemplate")
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
          rollbackRecord taskTemplate, phaseTemplate.get('taskTemplates')
          newPhaseTemplate = taskTemplate.get('phaseTemplate')
          if newPhaseTemplate != phaseTemplate
            phaseTemplate.get('taskTemplates').removeObject(taskTemplate)
            newPhaseTemplate.get('taskTemplates').pushObject(taskTemplate)
        rollbackRecord phaseTemplate, mmt.get('phaseTemplates')
        phaseTemplate.reloadHasManys()
      rollbackRecord mmt
      debugger
      @get('removedTasks').invoke('rollback')
      @set('removedTasks', [])
      @set('dirty', false)
      @send('didRollBack')

rollbackRecord = (model, parentAssociation) ->
  console.log(model.toString())
  if model.get('isNew')
    if parentAssociation
      parentAssociation.removeObject(model)
    model.deleteRecord()

  model.rollback()
