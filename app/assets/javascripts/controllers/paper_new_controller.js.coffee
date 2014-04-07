ETahi.PaperNewController = Ember.ArrayController.extend
  shortTitle: null
  journal: null

  actions:
    createNewPaper: ->
      self = @
      newPaper = @store.createRecord('paper', {
        journal: @get('journal')
        shortTitle: @get('shortTitle')
      })

      newPaper.save().then (paper) ->
        self.set('shortTitle', null)
        self.transitionToRoute('paper.edit', paper)
