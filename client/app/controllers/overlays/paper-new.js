import Ember from 'ember';
import Utils from 'tahi/services/utils';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen paper-new-overlay',
  journals: null,
  noJournalSelected: Ember.computed.not('model.journal'),

  journalProxies: function() {
    return this.get('journals').map(function(journal) {
      return {
        id: journal.get('id'),
        text: journal.get('name')
      };
    });
  }.property('journal.@each'),

  paperTypeProxies: function() {
    return this.get('model.journal.paperTypes').map(function(paperType) {
      return {
        id: Utils.generateUUID(),
        text: paperType
      };
    });
  }.property('model.journal.paperTypes.@each'),

  selectedJournal: function() {
    let journal = this.get('model.journal');
    if(Ember.isEmpty(journal)) { return; }

    return { id:   journal.get('id'),
             text: journal.get('name') };
  }.property('model.journal'),

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
    },

    selectJournal(journalProxy) {
      let journal = this.get('journals').findBy('id', journalProxy.id);
      this.set('model.journal', journal);
    },

    selectPaperType(paperTypeProxy) {
      let paperType = this.get('model.journal.paperTypes').findBy('id', paperTypeProxy.id);
      this.set('model.paperType', paperType);
    }
  }
});
