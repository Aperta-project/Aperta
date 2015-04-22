`import Ember from 'ember'`

PaperNewOverlayController = Ember.Controller.extend
  overlayClass: 'overlay--fullscreen paper-new-overlay'

  # set in route
  journals: null
  noJournalSelected: Ember.computed.not('model.journal')

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

`export default PaperNewOverlayController`
