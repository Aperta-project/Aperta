ETahi.PaperManageController = Ember.ObjectController.extend
  positionSort: ["position:asc"]
  sortedPhases: Ember.computed.sort('phases', 'positionSort')

  updatePositions: (phase)->
    relevantPhases = @get('model.phases').filter((p)->
      p != phase && p.get('position') >= phase.get('position')
    )

    relevantPhases.invoke('incrementProperty', 'position')

  paper: Ember.computed.alias('model')
  canRemoveCard: true

  actions:
    addPhase: (position) ->
      paper = @get('model')
      phase = @store.createRecord 'phase',
        position: position
        name: "New Phase"
        paper: paper
      @updatePositions(phase)
      phase.save().then ->
        paper.reload()

    changeTaskPhase: (task, targetPhase) ->
      task.set('phase', targetPhase)
      task.save()

    removePhase: (phase) ->
      paper = phase.get('paper')
      phase.destroyRecord().then ->
        paper.reload()

    removeTask: (task) ->
      task.destroyRecord()

    savePhase: (phase) ->
      phase.save()

    rollbackPhase: (phase) ->
      phase.rollback()

    toggleEditable: ->
      ETahi.RESTless.putUpdate(@get('model'), '/toggle_editable')
