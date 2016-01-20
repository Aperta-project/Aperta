import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

const { computed } = Ember;

export default Ember.Component.extend(EscapeListenerMixin, {
  restless: Ember.inject.service(),
  flash: Ember.inject.service(),
  journals: null,
  paper: null,
  isSaving: false,
  journalEmpty: computed.empty('paper.journal.content'),
  hasTitle: computed.notEmpty('paper.title'),

  actions: {
    selectJournal(journal) {
      this.set('paper.journal', journal);
      this.set('paper.paperType', null);
    },

    clearJournal() {
      this.set('paper.journal', null);
      this.set('paper.paperType', null);
    },

    selectPaperType(paperType) {
      this.set('paper.paperType', paperType);
    },

    clearPaperType() {
      this.set('paper.paperType', null);
    },

    fileAdded(file){
      this.set('isSaving', true);
    },

    uploadFinished(s3Url){
      this.get('paper').save().then((paper) => {
        const path = `/api/papers/${paper.id}/upload`;
        this.get('restless').put(path, {url: s3Url}).then(() => {
          this.attrs.complete(paper);
        });
      }, (response) => {
        this.set('isSaving', false);
        this.get('flash').displayErrorMessagesFromResponse(response);
      });
    },

    uploadFailed(reason) {
      this.set('isSaving', false);
      console.log(reason);
    },

    close() {
      this.attrs.close();
    }
  }
});
