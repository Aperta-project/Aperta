import Ember from 'ember';
import FileUpload from 'tahi/models/file-upload';
import extensionFont from 'tahi/lib/extension-font';

export default Ember.Component.extend({
  classNames: ['attachment-item'],
  attachment: null, // passed-in
  hasNote: false,
  fileUpload: null,
  note:null,
  uploadInProgress: Ember.computed.notEmpty('fileUpload'),

  fileTypeClass: Ember.computed('attachment.filename', function(){
    return extensionFont(this.get('attachment.filename'));
  }),

  init() {
    this._super(...arguments);
    Ember.assert('Please provide filePath property', this.get('filePath'));
  },

  actions: {

    deleteFile() {
      if (this.attrs.deleteFile) {
        this.attrs.deleteFile(this.get('attachment'));
      }
    },

    noteChanged() {
      if (this.attrs.noteChanged) {
        this.attrs.noteChanged(this.get('note'));
      }
    },

    fileAdded(file){
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
      this.set('fileUpload', null)
      if (this.attrs.uploadFinished) {
        this.attrs.uploadFinished(s3Url);
      }
    },

    uploadFailed(reason){
     console.log('uploadFailed', reason);
    }
  }
});
