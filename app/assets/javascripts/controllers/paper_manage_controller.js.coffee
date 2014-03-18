ETahi.PaperManageController = Ember.ObjectController.extend
  sortedPhases: ( ->
    Ember.ArrayProxy.createWithMixins(Em.SortableMixin, {
      content: @get('model.phases')
      sortProperties: ['position']
    })
  ).property('model.phases.@each')

  updatePositions: (phase)->
    relevantPhases = _(this.get('model.phases').content).filter((p)->
      p != phase && p.get('position') >= phase.get('position')
    )
    _(relevantPhases).each((p)->
      p.incrementProperty('position')
    )

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
      paper = task.get('phase.paper')
      task.destroyRecord().then ->
        paper.reload()

    addTask: ->
      @send('showGenericOverlay', 'new_task')


  refreshColumnHeights: (->
    Ember.run.next(this, Tahi.utils.resizeColumnHeaders)
  ).observes('phases.[]', 'phases.@each.name')
