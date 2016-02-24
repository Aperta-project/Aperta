import Ember from 'ember';
import FileUpload from 'tahi/models/file-upload';
import fontAwesomeFiletypeClass from 'tahi/lib/font-awesome-fyletype-class';

/**
 *  This component wraps the s3-file-uploader with a UI that handle actions like
 *  Delete and Replace, also displays an icon based on the filetype extension.
 *  This component is meant to be used within the attachment-manager component.

 *  ## How to Use
 *
 *  In your template:
 *
 *  ```
 *  {{attachment-item accept=accept
 *                    attachment=attachment
 *                    filePath=filePath
 *                    hasCaption=hasCaption
 *                    deleteFile=attrs.deleteFile
 *                    noteChanged=attrs.noteChanged
 *                    uploadFinished=attrs.uploadFinished}}
 *  ```
**/

export default Ember.Component.extend({
  classNames: ['attachment-item'],
  attachment: null, // passed-in
  hasCaption: false,
  fileUpload: null,
  caption: null,
  isProcessing: Ember.computed.equal('attachment.status', 'processing'),
  uploadInProgress: Ember.computed.notEmpty('fileUpload'),

  fileTypeClass: Ember.computed('attachment.filename', function(){
    return fontAwesomeFiletypeClass(this.get('attachment.filename'));
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

    captionChanged() {
      if (this.attrs.captionChanged) {
        this.attrs.captionChanged(this.get('caption'), this.get('attachment'));
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
      if (this.attrs.uploadFinished) {
        this.attrs.uploadFinished(s3Url,
                                  this.get('fileUpload.file'),
                                  this.get('attachment'));
      }
      this.set('fileUpload', null);
    },

    uploadFailed(reason){
     console.log('uploadFailed', reason);
    }
  }
});
