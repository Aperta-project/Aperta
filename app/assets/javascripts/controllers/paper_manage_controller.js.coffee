ETahi.PaperManageController = Ember.ObjectController.extend
  sortedPhases: ( ->
    Ember.ArrayProxy.createWithMixins(Em.SortableMixin, {
      content: @get('model.phases')
      sortProperties: ['position']
    })
  ).property('model.phases')

  actions:
    addPhase: (position) ->

    removePhase: (phase) ->
      paper = phase.get('paper')
      phase.destroyRecord().then (phase) ->
        paper.reload()
