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
 *                    hasCaption=hasCaption
 *                    deleteFile=attrs.deleteFile
 *                    noteChanged=attrs.noteChanged
 *                    uploadFinished=attrs.uploadFinished}}
 *  ```
**/

export default Ember.Component.extend({
  classNames: ['attachment-item'],
  classNameBindings: ['disabled:read-only'],
  attachment: null, // passed-in
  disabled: false,
  hasCaption: false,
  fileUpload: null,
  caption: null,
  isCanceled: false,
  isProcessing: Ember.computed.equal('attachment.status', 'processing'),
  isError: Ember.computed.equal('attachment.status', 'error'),
  uploadInProgress: Ember.computed.notEmpty('fileUpload'),

  fileTypeClass: Ember.computed('attachment.filename', function(){
    return fontAwesomeFiletypeClass(this.get('attachment.filename'));
  }),

  processingErrorMessage: Ember.computed('attachment.filename', function() {
    return `There was an error while processing ${this.get('attachment.filename')}. Please try again
    or contact Aperta staff.`;
  }),

  willDestroyElement() {
    this._super(...arguments);
    if (this.get('isCanceled') && this.get('attachment')) {
      this.get('attachment').unloadRecord();
    }
  },
  actions: {

    deleteFile() {
      if (this.attrs.deleteFile) {
        this.attrs.deleteFile(this.get('attachment'));
      }
    },

    cancelUpload() {
      this.set('isCanceled', true);
      this.get('cancelUpload')(this.get('attachment'));
    },


    captionChanged() {
      if (this.attrs.captionChanged) {
        this.attrs.captionChanged(this.get('caption'), this.get('attachment'));
      }
    },

    fileAdded(upload){
      this.set('attachment.readyIssues', []);
      this.set('fileUpload', FileUpload.create({ file: upload.files[0] }));
      if (this.get('fileAdded')) {
        this.get('fileAdded')(upload);
      }
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
    }
  }
});
