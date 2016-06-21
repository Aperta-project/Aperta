import Ember from 'ember';
import FileUpload from 'tahi/models/file-upload';

/**
 *  This component displays a UI where you can upload one or multiple files,
 *  Accepts multiple attributes like: attachments, filePath and actions.
 *
 *  ## How to Use
 *
 *  In your template:
 *
 *  ```
 *  {{attachment-manager accept=".jpg,.jpeg,.tiff,.tif,.gif,.png"
 *                       filePath="tasks/attachment"
 *                       hasCaption=true
 *                       attachments=task.attachments
 *                       noteChanged=(action "noteChanged")
 *                       deleteFile=(action "deleteAttachment")
 *                       uploadFinished=(action "uploadFinished")}}
 *  ```
**/

export default Ember.Component.extend({
  classNames: ['attachment-manager'],
  classNameBindings: ['disabled:read-only'],
  description: 'Please select a file.',
  disabled: false,
  notDisabled: Ember.computed.not('disable'),
  buttonText: 'Upload File',
  fileUploads: [],
  multiple: false,
  uploadInProgress: Ember.computed.notEmpty('fileUploads'),
  hasAttachments: Ember.computed.notEmpty('attachments'),
  noAttachments: Ember.computed.not('hasAttachments'),
  canUploadFile: Ember.computed.or('noAttachments', 'multiple'),
  showAddButton: Ember.computed.and('notDisabled', 'canUploadFile'),

  init() {
    this._super(...arguments);
    Ember.assert('Please provide filePath property', this.get('filePath'));
    if (!this.get('attachments')) this.set('attachments', []);
  },

  actions: {

    fileAdded(file){
      this.get('fileUploads').addObject(FileUpload.create({ file: file }));
    },

    uploadProgress(data) {
      const fileName = data.files[0].name;
      const upload = this.get('fileUploads').findBy('file.name', fileName);

      upload.setProperties({
        dataLoaded: data.loaded,
        dataTotal: data.total
      });
    },

    uploadFinished(s3Url, data){
      const fileName = data.files[0].name,
        uploads = this.get('fileUploads'),
        upload = uploads.findBy('file.name', fileName);

      if (this.attrs.uploadFinished) {
        this.attrs.uploadFinished(s3Url, upload.get('file'));
      }

      uploads.removeObject(upload);
    },

    uploadFailed(reason){
     console.log('uploadFailed', reason);
    }
  }
});
