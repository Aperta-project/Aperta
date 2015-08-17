import Ember from 'ember';
import AnimateOverlay from 'tahi/mixins/animate-overlay';

export default Ember.Controller.extend(AnimateOverlay, {
  overlayClass: 'overlay--fullscreen paper-new-overlay',
  journals: null, // set on controller before rendering overlay
  paperSaving: false,
  journalEmpty: Ember.computed.empty('model.journal'),

  shortTitleCount: Ember.computed('model.shortTitle', function() {
    let title = this.get('model.shortTitle');
    return title ? title.length : 0;
  }),

  actions: {
    createNewPaper() {
      this.set('paperSaving', true);

      this.get('model').save().then((paper)=> {
        this.transitionToRoute('paper.edit', paper);
      }, (response)=> {
        this.flash.displayErrorMessagesFromResponse(response);
      }).finally(()=> {
        this.set('paperSaving', false);
      });
    },

    selectJournal(journal) {
      this.set('model.journal', journal);
      this.set('model.paperType', null);
    },

    clearJournal() {
      this.set('model.journal', null);
      this.set('model.paperType', null);
    },

    selectPaperType(paperType) {
      this.set('model.paperType', paperType);
    },

    clearPaperType() {
      this.set('model.paperType', null);
    }
  }
});
