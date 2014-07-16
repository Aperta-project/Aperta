ETahi.PaperNewController = Ember.ObjectController.extend
  needs: ['application']

  journalDidChange: (->
    @set('model.paperType', @get('model.journal.paperTypes.firstObject'))
  ).observes('model.journal')

  actions:
    createNewPaper: ->
      @get('model').save().then (paper) =>
        @send('addPaperToEventStream', paper)
        @transitionToRoute('paper.edit', paper)
