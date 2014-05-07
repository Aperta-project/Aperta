ETahi.PaperNewController = Ember.ObjectController.extend
  actions:
    createNewPaper: ->
      @get('model').save().then (paper) =>
        @set('shortTitle', null)
        @transitionToRoute('paper.edit', paper)
