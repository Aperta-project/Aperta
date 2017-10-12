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

  orderedPaperTypeNames: [
    'Research Article',
    'Short Reports',
    'Methods and Resources',
    'Meta-Research Article',
    'Essay',
    'Perspective',
    'Community Page',
    'Unsolved Mystery',
    'Primer (invitation only)',
    'Research Matters (invitation only)',
    'Formal Comment (invitation only)',
    'Editorial (staff use only)',
    'Open Highlights (staff use only)'
  ],

  // This is a short-term solution for ordering paper types based entirely on
  // PLOS Biology's needs. We expect to replace this with something more
  // user configurable in the future. APERTA-11315
  orderedPaperTypes: Ember.computed('orderedPaperTypeNames.[]', 'paper.journal.manuscriptManagerTemplates.[]', function() {
    const orderedPaperTypes = Ember.A();
    return this.get('paper.journal').then((journal) => {
      if (!journal) { return orderedPaperTypes; }
      const mmts = journal.get('manuscriptManagerTemplates').copy();
      this.get('orderedPaperTypeNames').forEach((name) => {
        const match = mmts.find((mmt) => {
          return mmt.paper_type === name;
        });
        if (match) {
          orderedPaperTypes.push(match);
          mmts.removeObject(match);
        }
      });
      return orderedPaperTypes.pushObjects(mmts.sortBy('paper_type'));
    });
  }),

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
