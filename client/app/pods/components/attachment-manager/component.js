import Ember from 'ember';
import FileUpload from 'tahi/models/file-upload';

export default Ember.Component.extend({
  classNames: ['attachment-manager'],
  description: 'Please select a file.',
  buttonText: 'Upload File',
  hasFile: false,
  fileName: null,
  fileType: null,
  fileUpload: null,
  uploadInProgress: Ember.computed.notEmpty('fileUpload'),

  actions: {

    delete() {
      console.log('delete');
    },

    fileAdded(file){
      this.setProperties({ fileName: file.name, fileType: file.type });
      this.set('fileUpload', FileUpload.create({ file: file }));
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
     console.log('uploadFinished', s3Url);
     this.set('hasFile', true);
     this.set('fileUpload', null);
    },

    uploadFailed(reason){
     console.log('uploadFailed', reason);
    }
  }
});
