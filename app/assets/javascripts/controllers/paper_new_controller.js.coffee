ETahi.PaperNewController = Ember.ObjectController.extend
  journalDidChange: (->
    @set('model.paperType', @get('model.journal.paperTypes.firstObject'))
  ).observes('model.journal')

  actions:
    createNewPaper: ->
      @get('model').save().then (paper) =>
        @transitionToRoute('paper.edit', paper)
