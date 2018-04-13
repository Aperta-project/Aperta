/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import Ember from 'ember';
import FileUpload from 'tahi/pods/file-upload/model';
import { task as concurrencyTask, timeout } from 'ember-concurrency';

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
 *                       uploadFinished=(action "uploadFinished")}}
 *  ```
 *
 *  Note that attachment-manager has default implementations for deleting an existing attachment and for cancelling
 * an upload.  You can pass a 'deleteFile' and 'cancelUpload' to override them.
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
  allowDelete: true,
  attachments: null, // passed in

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

  cancelAttachmentUpload: concurrencyTask(function * (attachment) {
    yield attachment.cancelUpload();
    yield timeout(5000);
    attachment.unloadRecord();
  }),


  actions: {
    fileAdded(upload) {
      this.set('uploadErrorMessage', null);
      this.get('fileUploads').addObject(
        FileUpload.create({ file: upload.files[0] })
      );
    },

    /**
     * The default behavior for canceling an attachment upload is to defer to the
     * attachment's cancel behavior, wait 5 seconds, and then unload the record from the client.  callers of attachment-manager can also pass a 'cancelUpload' action if they need to
     * do something different.
     */
    cancelUpload(attachment) {
      if (this.get('cancelUpload')) {
        this.get('cancelUpload')(attachment);
      } else {
        this.get('cancelAttachmentUpload').perform(attachment);
      }
    },

    deleteAttachment(attachment) {
      if (this.get('deleteFile')) {
        this.get('deleteFile')(attachment);
      } else {
        attachment.destroyRecord();
      }
    },

    updateAttachmentCaption(caption, attachment) {
      attachment.set('caption', caption);
      attachment.save();
    },

    clearError() {
      this.set('uploadErrorMessage', null);
    },

    uploadProgress(data) {
      const fileName = data.files[0].name;
      const upload = this.get('fileUploads').findBy('file.name', fileName);

      upload.setProperties({
        dataLoaded: data.loaded,
        dataTotal: data.total
      });
    },

    /**
     * uploadError will either set the message provided by the action or
     * override it with a hardcoded error message that's been passed in to attachment-manager
     */
    uploadError(message) {
      if (this.get('errorMessage')) {
        this.set('uploadErrorMessage', this.get('errorMessage'));
      } else {
        this.set('uploadErrorMessage', message);
      }
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
