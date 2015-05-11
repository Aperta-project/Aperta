import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen paper-new-overlay',
  journals: null,
  noJournalSelected: Ember.computed.not('model.journal'),

  journalDidChange: function() {
    this.set('model.paperType', this.get('model.journal.paperTypes.firstObject'));
  }.observes('model.journal'),

  actions: {
    createNewPaper() {
      this.get('model').save().then((paper)=> {
        this.send('addPaperToEventStream', paper);
        this.transitionToRoute('paper.edit', paper);
      }, (response)=> {
        this.flash.displayErrorMessagesFromResponse(response);
      });
    }
  }
});
