ETahi.PaperNewController = Ember.ObjectController.extend
  needs: ['application']

  journalDidChange: (->
    @set('model.paperType', @get('model.journal.paperTypes.firstObject'))
  ).observes('model.journal')

  actions:
    createNewPaper: ->
      @get('model').save().then (paper) =>
        @get('controllers.application').addEventListener(paper.get('eventName'))
        @transitionToRoute('paper.edit', paper)
