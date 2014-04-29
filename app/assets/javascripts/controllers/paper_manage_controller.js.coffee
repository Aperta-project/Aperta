ETahi.PaperManageController = Ember.ObjectController.extend
  sortedPhases: ( ->
    Ember.ArrayProxy.createWithMixins(Em.SortableMixin, {
      content: @get('model.phases')
      sortProperties: ['position']
    })
  ).property('model.phases.[], model.phases.tasks.@each')

  updatePositions: (phase)->
    relevantPhases = @get('model.phases').filter((p)->
      p != phase && p.get('position') >= phase.get('position')
    )

    relevantPhases.invoke('incrementProperty', 'position')


  actions:
    addPhase: (position) ->
      paper = @get('model')
      phase = @store.createRecord 'phase',
        position: position + 1
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
