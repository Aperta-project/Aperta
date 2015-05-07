import Ember from 'ember';
import FileUploadMixin from 'tahi/mixins/file-upload';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(FileUploadMixin, ValidationErrorsMixin, {
  tagName: 'li',
  classNames: ['journal'],

  canEdit: false,
  logoPreview: null,
  journal: null,
  uploadLogoFunction: null,
  isEditing: false,

  modelIsDirtyDidChange: function() {
    this.set('isEditing', this.get('model.isDirty'));
  }.on('init').observes('model.isDirty'),

  thumbnailId: function() {
    return 'journal-logo-' + (this.get('model.id'));
  }.property('model.id'),

  logoUploadUrl: function() {
    return '/api/admin/journals/' + this.get('model.id') + '/upload_logo';
  }.property('model.id'),

  togglePreview: function() {
    Ember.run(() => {
      Ember.run.schedule('afterRender', ()=> {
        if (this.get('logoPreview')) {
          return this.$('.journal-logo-preview').empty().append(this.get('logoPreview'));
        } else {
          return this.$('.journal-logo-preview').html('');
        }
      });
    });
  }.observes('logoPreview'),

  stopEditing: function() {
    this.setProperties({
      isEditing: false,
      uploadLogoFunction: null,
      logoPreview: null
    });
  },

  saveJournal: function() {
    this.get('model').save().then(()=> {
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
      this.set('model.logoUrl', data.admin_journal.logo_url);
      this.saveJournal();
    },

    saveJournalDetails() {
      let updateLogo = this.get('uploadLogoFunction');

      if(this.get('model.isNew')) {
        this.get('model').save().then(() => {
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
      this.get('model').rollback();
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
