import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['journal-logo-uploader'],
  allowedFileTypes: '.jpg,.jpeg,.eps,.png',

  logoUrl: null,
  errorMessage: null,

  saving: false,

  clearErrors() {
    this.set('errorMessage', '');
  },

  actions: {
    fileAdded() {
      this.set('saving', true);
      this.clearErrors();
    },

    addingFileFailed(message) {
      this.set('saving', false);
      this.set('errorMessage', message);
    },

    uploadFinished(s3Url) {
      this.set('saving', false);
      this.clearErrors();
      this.set('logoUrl', s3Url);
    },

    uploadFailed(message) {
      this.set('saving', false);
      this.set('errorMessage', message);
    }
  }
});
