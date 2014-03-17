ETahi.PaperManageController = Ember.ObjectController.extend
  sortedPhases: ( ->
    Ember.ArrayProxy.createWithMixins(Em.SortableMixin, {
      content: @get('model.phases')
      sortProperties: ['position']
    })
  ).property('model.phases.@each')

  actions:
    addPhase: (position) ->
      paper = @get('model')
      phase = @store.createRecord 'phase',
        position: position + 1
        name: "New Phase"
        paper: paper
      phase.save().then ->
        paper.reload()

    removePhase: (phase) ->
      paper = phase.get('paper')
      phase.destroyRecord().then ->
        paper.reload()

  refreshColumnHeights: (->
    Ember.run.next(this, Tahi.utils.resizeColumnHeaders)
  ).observes('phases.[]')
