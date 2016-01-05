import Ember from 'ember';
import FileUpload from 'tahi/models/file-upload';
import extensionFont from 'tahi/lib/extension-font';

export default Ember.Component.extend({
  classNames: ['attachment-manager'],
  description: 'Please select a file.',
  buttonText: 'Upload File',
  hasFile: false,
  hasNote: false,
  fileName: null,
  fileUpload: null,
  note:null,
  uploadInProgress: Ember.computed.notEmpty('fileUpload'),

  fileTypeClass: Ember.computed('fileName', function(){
    return extensionFont(this.get('fileName'));
  }),

  init() {
      this._super(...arguments);
      Ember.assert('Please provide filePath property', this.get('filePath'));
  },

  actions: {

    deleteFile() {
      if (this.attrs.deleteFile) {
        this.attrs.deleteFile();
      }
      this.set('hasFile', false);
    },

    fileAdded(file){
      this.setProperties({ fileName: file.name,
                           fileUpload: FileUpload.create({ file: file })});
    },

    triggerFileSelection() {
      this.$().find('input').click();
    },

    uploadProgress(data) {
      this.get('fileUpload').setProperties({
        dataLoaded: data.loaded,
        dataTotal: data.total
      });
    },

    uploadFinished(s3Url){
      this.setProperties({hasFile: true, fileUpload: null});
     if (this.attrs.uploadFinished) {
       this.attrs.uploadFinished(s3Url);
     }
    },

    uploadFailed(reason){
     console.log('uploadFailed', reason);
    }
  }
});
