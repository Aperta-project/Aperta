ETahi.ManuscriptManagerTemplateEditController = Ember.ObjectController.extend
  dirty: false
  errorText: ""
  editMode: false
  journal: Em.computed.alias('model.journal')

  sortedPhases: Ember.computed.alias 'phaseTemplates'

  deletedRecords: null

  showSaveButton: (->
    @get('dirty') || @get('editMode')
  ).property('dirty', 'editMode')

  deleteRecord: (record) ->
    deleted = @get('deletedRecords') || []
    deleted.addObject(record)
    record.deleteRecord()
    @setProperties
      deletedRecords: deleted
      dirty: true

  successfulSave: (transition) ->
    @reset()
    @set('errorText', '')
    if transition
      transition.retry()
    else
      @transitionToRoute('manuscript_manager_template.edit', @get('model'))

  reset: () ->
    @setProperties
      editMode: false
      dirty: false
      deletedRecords: []

  actions:
    toggleEditMode: ->
      @toggleProperty 'editMode'
      return null

    changeTaskPhase: (taskTemplate, targetPhaseTemplate) ->
      newPosition = targetPhaseTemplate.get('length')
      taskTemplate.setProperties
        phaseTemplate: targetPhaseTemplate
        position: newPosition
      targetPhaseTemplate.get('taskTemplates').pushObject(taskTemplate)
      @set('dirty', true)

    addPhase: (position) ->
      @get('model.phaseTemplates').forEach (phaseTemplate) ->
        if phaseTemplate.get('position') >= position
          phaseTemplate.incrementProperty('position')

      @store.createRecord 'phaseTemplate',
        name: 'New Phase'
        manuscriptManagerTemplate: @get('model')
        position: position

      @set('dirty', true)

    removePhase: (phaseTemplate) ->
      @deleteRecord phaseTemplate

    rollbackPhase: (phase, oldName) ->
      phase.set('name', oldName)

    addTask: (phaseTemplate, journalTaskType) ->
      unless Ember.isBlank(journalTaskType)
        newTask = @store.createRecord('taskTemplate', journalTaskType: journalTaskType, phaseTemplate: phaseTemplate)
        @set('dirty', true)

    removeTask: (taskTemplate) ->
      @deleteRecord taskTemplate

    savePhase: (phase) ->
      @set('dirty', true)
      null

    saveTemplate: (transition)->
      @get('model').save().then( (mmt) =>
        taskTemplates = []

        Em.RSVP.all(mmt.get('phaseTemplates').invoke('save')).then (phaseTemplates) =>
          promises = phaseTemplates.map (phaseTemplate) ->
            phaseTemplate.get('taskTemplates').invoke('save')

          Em.RSVP.all(promises.compact()).then =>
            if deletedRecords = @get('deletedRecords')
              Em.RSVP.all(deletedRecords.invoke('save')).then =>
                @successfulSave(transition)
            else
              @successfulSave(transition)

      ).catch (errorResponse) =>
        if errorResponse.status == 422
          errors = _.values(errorResponse.responseJSON.errors).join(' ')
        else
          errors = "There was an error saving your changes. Please try again"
        Tahi.utils.togglePropertyAfterDelay(this, 'errorText', errors, '', 5000)

    rollback: ->
      if @get('model.isNew')
        @get('model').deleteRecord()
        @reset()
        @send('didRollBack')
      else
        @store.unloadAll('taskTemplate')
        @store.unloadAll('phaseTemplate')
        @get('model').rollback()
        @get('model').reload().then =>
          @reset()
          @send('didRollBack')

