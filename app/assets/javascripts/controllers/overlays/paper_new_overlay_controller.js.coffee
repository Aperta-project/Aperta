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
        # TODO: this is an ember data bug that will likely be solved after upgrading
        # to beta 11 or later.  check back then.
        paper.reload().then (newPaper) =>
          @transitionToRoute('paper.edit', newPaper)
      , (errors) ->
        if error = errors.errors.shortTitle
          Tahi.utils.displayErrorMessage "Short title " + error
