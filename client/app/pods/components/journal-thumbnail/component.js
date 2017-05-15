import Ember from 'ember';
import FileUploadMixin from 'tahi/mixins/file-upload';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(FileUploadMixin, ValidationErrorsMixin, {
  classNames: ['journal-thumbnail'],
  canEdit: null,   // passed-in,
  journal: null,   // passed-in,
  isEditing: false,
  isCreating: false,
  isSaving: false,
  showForm: Ember.computed.or('isEditing', 'isCreating', 'journal.isNew'),

  setJournalProperties() {
    const desc = this.get('journal.description') || '';
    let name = this.get('journal.name') || '';
    this.get('journal').setProperties({
      name: name.trim(),
      description: desc.trim() || null
    });
  },

  stopEditing() {
    this.setProperties({
      isEditing: false,
      isCreating: false
    });
  },

  saveJournal() {
    this.set('isSaving', true);
    this.setJournalProperties();

    this.get('journal').save().then(()=> {
      this.stopEditing();
      this.clearAllValidationErrors();
      if(this.get('afterSave')) {
        this.get('afterSave')();
      }
    }, (response) => {
      this.displayValidationErrorsFromResponse(response);
    }).finally(() => {
      this.set('isSaving', false);
    });
  },

  actions: {

    editJournal() {
      this.set('isEditing', true);
    },

    saveJournalDetails() {
      if(this.get('journal.isNew')) {

        this.set('isCreating', true);
        this.setJournalProperties();

        this.get('journal').save().then(() => {
          this.clearAllValidationErrors();
          return (this.stopEditing).call(this);
        }, (response) => {
          this.clearAllValidationErrors();
          this.displayValidationErrorsFromResponse(response);
        });

      } else {
        this.saveJournal();
      }
    },

    cancel() {
      this.get('journal').rollbackAttributes();
      this.stopEditing();
      this.clearAllValidationErrors();
    },

  }
});
