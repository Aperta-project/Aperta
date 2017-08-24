import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';
import checkType, { filetypeRegex } from 'tahi/lib/file-upload/check-filetypes';

const { computed } = Ember;

export default Ember.Component.extend(EscapeListenerMixin, {
  fileTypes: computed('pdfEnabled', function() {
    if (this.get('pdfEnabled')) {
      return '.doc,.docx,.pdf'
    } else {
      return '.doc,.docx'
    }
  }),
  restless: Ember.inject.service(),
  flash: Ember.inject.service(),
  journals: null,
  paper: null,
  isSaving: false,
  pdfEnabled: computed.reads('paper.journal.pdfAllowed'),
  journalEmpty: computed.empty('paper.journal.content'),
  hasTitle: computed.notEmpty('paper.title'),

  actions: {
    titleChanged(contents) {
      this.set('paper.title', contents);
    },

    selectJournal(journal) {
      this.set('paper.journal', journal);
      this.set('paper.paperType', null);
    },

    clearJournal() {
      this.set('paper.journal', null);
      this.set('paper.paperType', null);
    },

    selectPaperType(template) {
      this.set('paper.paperType', template.paper_type);
      this.set('template', template);
    },

    clearPaperType() {
      this.set('paper.paperType', null);
    },

    fileAdded(upload){
      let check = checkType(upload.files[0].name, this.get('fileTypes'));
      if (!check.error) {
        this.set('paper.fileType', check['acceptedFileType']);
        this.set('isSaving', true);
      } else {
        this.set('isSaving', false);
        this.get('flash').displayRouteLevelMessage(check.msg);
      }
    },

    addingFileFailed(reason, message, {fileName, acceptedFileTypes}) {
      this.set('isSaving', false);
      this.get('flash').displayRouteLevelMessage('error', message);
    },

    uploadFinished(s3Url){
      let paper = this.get('paper'),
        template = this.get('template');
      paper.set('url', s3Url);
      paper.save().then((paper) => {
        this.attrs.complete(paper, template);
      } , (response) => {
        this.get('flash').displayErrorMessagesFromResponse(response);
      }).finally(() => {
        this.set('isSaving', false);
      });
    },

    uploadFailed(reason){
      this.set('isSaving', false);
      this.get('flash').displayRouteLevelMessage('error', reason);
      console.log(reason);
    },

    close() {
      this.attrs.close();
    }
  }
});
