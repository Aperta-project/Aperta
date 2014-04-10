ETahi.PaperManageController = Ember.ObjectController.extend
  sortedPhases: ( ->
    Ember.ArrayProxy.createWithMixins(Em.SortableMixin, {
      content: @get('model.phases')
      sortProperties: ['position']
    })
  ).property('model.phases.@each')

  updatePositions: (phase)->
    relevantPhases = @get('model.phases').filter((p)->
      p != phase && p.get('position') >= phase.get('position')
    )

    relevantPhases.invoke('incrementProperty', 'position')

  changeTaskPhase: (taskID, newPhase) ->
    #this.store.find('task', taskID).then (task)->
      #task.set('phase', newPhase)
      #oldPhase.save()
      #newPhase.save()


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

    removePhase: (phase) ->
      paper = phase.get('paper')
      phase.destroyRecord().then ->
        paper.reload()

    removeTask: (task) ->
      task.destroyRecord()
