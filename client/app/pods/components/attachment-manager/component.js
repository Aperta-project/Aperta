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

let { computed } = Ember;
export default Ember.Component.extend({
  classNames: ['attachment-manager'],
  classNameBindings: ['disabled:read-only'],
  description: 'Please select a file.',
  disabled: false,
  notDisabled: computed.not('disabled'),
  buttonText: 'Upload File',
  fileUploads: computed(() => {
    return [];
  }),
  multiple: false,
  showDescription: true,
  alwaysShowAddButton: false,
  preview: false, // used for the card config editor
  uploadErrorMessage: null, // set in the uploadError action

  uploadInProgress: computed.notEmpty('fileUploads'),
  canUploadMoreFiles: computed('attachments.[]', 'multiple', function() {
    return Ember.isEmpty(this.get('attachments')) || this.get('multiple');
  }),

  disableAddButton: computed(
    'uploadInProgress',
    'disabled',
    'preview',
    function() {
      return (
        this.get('uploadInProgress') ||
        this.get('disabled') ||
        this.get('preview')
      );
    }
  ),

  showAddButton: computed(
    'alwaysShowAddButton',
    'disabled',
    'canUploadMoreFiles',
    function() {
      return (
        this.get('alwaysShowAddButton') ||
        (this.get('canUploadMoreFiles') && !this.get('disabled'))
      );
    }
  ),

  init() {
    this._super(...arguments);
    Ember.assert('Please provide filePath property', this.get('filePath'));
    if (!this.get('attachments')) this.set('attachments', []);
  },

  actions: {
    fileAdded(upload) {
      this.set('uploadErrorMessage', null);
      this.get('fileUploads').addObject(
        FileUpload.create({ file: upload.files[0] })
      );
    },

    uploadProgress(data) {
      const fileName = data.files[0].name;
      const upload = this.get('fileUploads').findBy('file.name', fileName);

      upload.setProperties({
        dataLoaded: data.loaded,
        dataTotal: data.total
      });
    },

    uploadError(message) {
      this.set('uploadErrorMessage', message);
    },

    uploadFinished(s3Url, fileName) {
      const uploads = this.get('fileUploads'),
        upload = uploads.findBy('file.name', fileName);

      if (this.attrs.uploadFinished) {
        this.attrs.uploadFinished(s3Url, upload.get('file'));
      }

      uploads.removeObject(upload);
    }
  }
});
