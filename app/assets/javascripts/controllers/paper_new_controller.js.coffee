ETahi.PaperNewController = Ember.ObjectController.extend
  actions:
    createNewPaper: ->
      @get('model').save().then (paper) =>
        @transitionToRoute('paper.edit', paper)
