import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNames: ['well'],
  canEdit: null,   // passed-in,
  journal: null,   // passed-in,
  uploadLogoFunction: null,

  inputClassNames: ['form-control'],

  thumbnailId: Ember.computed('journal.id', function() {
    return `journal-logo-${this.get('journal.id')}`;
  }),

  logoUploadUrl: Ember.computed('journal.id', function() {
    return `/api/admin/journals/${this.get('journal.id')}/upload_logo`;
  }),

  // saveJournal() {

  //   this.setJournalProperties();

  //   this.get('journal').save().then(()=> {
  //     this.stopEditing();
  //   }, (response) => {
  //     this.displayValidationErrorsFromResponse(response);
  //   });
  // },

  actions: {
  }
});
