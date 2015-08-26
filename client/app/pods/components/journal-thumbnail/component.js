import Ember from 'ember';
import FileUploadMixin from 'tahi/mixins/file-upload';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(FileUploadMixin, ValidationErrorsMixin, {
  classNames: ['journal-thumbnail'],
  canEdit: null,   // passed-in,
  journal: null,   // passed-in,
  isEditing: false,
  logoPreview: null,
  uploadLogoFunction: null,

  modelIsDirtyDidChange: function() {
    this.set('isEditing', this.get('journal.isDirty'));
  }.on('init').observes('journal.isDirty'),

  thumbnailId: Ember.computed('journal.id', function() {
    return `journal-logo-${this.get('journal.id')}`;
  }),

  logoUploadUrl: Ember.computed('journal.id', function() {
    return `/api/admin/journals/${this.get('journal.id')}/upload_logo`;
  }),

  togglePreview() {
    Ember.run(() => {
      Ember.run.schedule('afterRender', ()=> {
        if (this.get('logoPreview')) {
          return this.$('.journal-thumbnail-logo-preview').empty().append(this.get('logoPreview'));
        } else {
          return this.$('.journal-thumbnail-logo-preview').html('');
        }
      });
    });
  },

  stopEditing() {
    this.setProperties({
      isEditing: false,
      uploadLogoFunction: null,
      logoPreview: null
    });
  },

  saveJournal() {

    this.get('journal').setProperties({
      name: this.get('journal.name').trim('string'),
      description: this.get('journal.description') || null
    });

    this.get('journal').save().then(()=> {
      this.stopEditing();
    }, (response)=> {
      this.displayValidationErrorsFromResponse(response);
    });
  },

  actions: {
    editJournalDetails() {
      this.set('isEditing', true);
    },

    uploadFinished(data, filename) {
      this.uploadFinished(data, filename);
      this.set('journal.logoUrl', data.admin_journal.logo_url);
      this.saveJournal();
    },

    saveJournalDetails() {
      let updateLogo = this.get('uploadLogoFunction');

      if(this.get('journal.isNew')) {

        this.get('journal').setProperties({
          name: this.get('journal.name').trim('string'),
          description: this.get('journal.description') || null
        });

        this.get('journal').save().then(() => {
          return (updateLogo || this.stopEditing).call(this);
        }, (response) => {
          this.displayValidationErrorsFromResponse(response);
        });

      } else {
        // updateLogo will fire the 'uploadFinished' action from the component, thus saving the model
        // with the new journal logo url.
        return (updateLogo || this.saveJournal).call(this);
      }
    },

    resetJournalDetails() {
      this.get('journal').rollback();
      this.set('isEditing', false);
      this.clearAllValidationErrors();
    },

    showPreview(file) {
      this.set('logoPreview', file.preview);
    },

    uploadReady(uploadLogoFunction) {
      this.set('uploadLogoFunction', uploadLogoFunction);
    }
  }
});
