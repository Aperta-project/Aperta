import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';
import checkType, { filetypeRegex } from 'tahi/lib/file-upload/check-filetypes';

const { computed } = Ember;

export default Ember.Component.extend(EscapeListenerMixin, {
  restless: Ember.inject.service(),
  flash: Ember.inject.service(),
  journals: null,
  paper: null,
  isSaving: false,
  pdfEnabled: computed.reads('paper.journal.pdfAllowed'),
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
      let check = checkType(file.name, '.doc, .docx, .pdf');
      this.set('paper.fileType', check['acceptedFileType'])
      this.set('isSaving', true);
    },

    addingFileFailed(reason, message, {fileName, acceptedFileTypes}) {
      this.set('isSaving', false);
      this.get('flash').displayMessage('error', message);
    },

    uploadFinished(s3Url){
      let paper = this.get('paper')
      paper.set('url', s3Url);
      paper.save().then((paper) => {
        this.attrs.complete(paper);
      } , (response) => {
        this.get('flash').displayErrorMessagesFromResponse(response);
      }).finally(() => {
        this.set('isSaving', false);
      });
    },

    uploadFailed(reason){
      this.set('isSaving', false);
      this.get('flash').displayMessage('error', reason);
      console.log(reason);
    },

    close() {
      this.attrs.close();
    }
  }
});
