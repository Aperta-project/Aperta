`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`
`import ValidationErrorsMixin from 'tahi/mixins/validation-errors'`

ManuscriptManagerTemplateEditController = Ember.Controller.extend ValidationErrorsMixin,
  dirty: false
  editMode: false
  journal: Ember.computed.alias('model.journal')

  positionSort: ["position:asc"]
  sortedPhaseTemplates: Ember.computed.sort('model.phaseTemplates', 'positionSort')

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

  saveTemplate: (transition) ->
    @get('model').save()

  successfulSave: (transition) ->
    @reset()
    if transition
      @transitionToRoute(transition)
    else
      @transitionToRoute('admin.journal.manuscript_manager_template.edit', @get('model'))

  reset: () ->
    @setProperties
      editMode: false
      dirty: false
      deletedRecords: []

  actions:
    toggleEditMode: ->
      @clearAllValidationErrors()
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

    removeTask: (taskTemplate) ->
      @deleteRecord taskTemplate

    savePhase: (phase) ->
      @set('dirty', true)
      null

    saveTemplateOnClick: (transition) ->
      if @get('dirty') || @get('editMode')
        @saveTemplate(transition)
      else
        @send 'rollback'

    rollback: ->
      if @get('model.isNew')
        @get('model').deleteRecord()
        @reset()
      else
        @store.unloadAll('taskTemplate')
        @store.unloadAll('phaseTemplate')
        @get('model').rollback()
        @get('model').reload().then =>
          @reset()

`export default ManuscriptManagerTemplateEditController`
