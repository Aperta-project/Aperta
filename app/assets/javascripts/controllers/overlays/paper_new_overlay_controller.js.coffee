ETahi.PaperNewOverlayController = Ember.ObjectController.extend
  overlayClass: 'overlay--fullscreen paper-new-overlay'

  noJournalSelected: Em.computed.not('model.journal')

  journalDidChange: (->
    @set('model.paperType', @get('model.journal.paperTypes.firstObject'))
  ).observes('model.journal')

  actions:
    createNewPaper: ->
      @get('model').save().then (paper) =>
        @send('addPaperToEventStream', paper)
        @transitionToRoute 'paper.edit', paper
      , (response) =>
        @flash.displayErrorMessagesFromResponse response
