import Ember from 'ember';
import FileUpload from 'tahi/models/file-upload';
import extensionFont from 'tahi/lib/extension-font';

export default Ember.Component.extend({
  classNames: ['attachment-manager'],
  description: 'Please select a file.',
  buttonText: 'Upload File',
  fileUpload: null,
  uploadInProgress: Ember.computed.notEmpty('fileUpload'),
  multiple: false,
  hasUploads: Ember.computed.notEmpty('attachments'),
  showAddButton: Ember.computed('multiple', 'hasUploads', function() {
    if (this.get('hasUploads') && !this.get('multiple')) return false;
    return true;
  }),

  init() {
    this._super(...arguments);
    Ember.assert('Please provide filePath property', this.get('filePath'));
    if (!this.get('attachments')) this.set('attachments', []);
  },

  actions: {

    fileAdded(file){
      this.set('fileUpload', FileUpload.create({ file: file }));
    },

    uploadProgress(data) {
      this.get('fileUpload').setProperties({
        dataLoaded: data.loaded,
        dataTotal: data.total
      });
    },

    uploadFinished(s3Url){
      if (this.attrs.uploadFinished) {
        this.attrs.uploadFinished(s3Url, this.get('fileUpload.file'));
      }
      this.set('fileUpload', null)
    },

    uploadFailed(reason){
     console.log('uploadFailed', reason);
    }
  }
});
