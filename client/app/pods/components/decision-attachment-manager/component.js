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

/**
 *  This component displays a UI where you can upload one or multiple files,
 *  Accepts multiple attributes like: attachments, filePath and actions.
 *
 *  ## How to Use
 *
 *  In your template:
 *
 *  ```
 *  {{decision-attachment-manager accept=".jpg,.jpeg,.tiff,.tif,.gif,.png"
 *                       filePath="decisions/attachment"
 *                       hasCaption=true
 *                       attachments=latestRegisteredDecision.attachments
 *                       noteChanged=(action "noteChanged")
 *                       deleteFile=(action "deleteAttachment")
 *                       uploadFinished=(action "uploadFinished")}}
 *  ```
**/

let { computed } = Ember;
export default Ember.Component.extend({
  classNames: ['decision-attachment-manager'],
  classNameBindings: ['disabled:read-only'],
  description: 'Please select a file.',
  disabled: false,
  notDisabled: computed.not('disabled'),
  buttonText: 'Upload File',
  fileUploads: computed(() => { return []; }),
  multiple: false,
  showDescription: true,
  alwaysShowAddButton: false,

  uploadInProgress: computed.notEmpty('fileUploads'),
  canUploadMoreFiles: computed('attachments.[]', 'multiple', function() {
    return Ember.isEmpty(this.get('attachments')) || this.get('multiple');
  }),

  showAddButton: computed(
    'alwaysShowAddButton',
    'disabled',
    'canUploadMoreFiles',
    function() {
      return this.get('alwaysShowAddButton') || (this.get('canUploadMoreFiles') && !this.get('disabled'));
    }
  ),

  init() {
    this._super(...arguments);
    Ember.assert('Please provide filePath property', this.get('filePath'));
    if (!this.get('attachments')) this.set('attachments', []);
  },

  actions: {

    fileAdded(upload){
      this.get('fileUploads').addObject(FileUpload.create({ file: upload.files[0] }));
    },

    uploadProgress(data) {
      const fileName = data.files[0].name;
      const upload = this.get('fileUploads').findBy('file.name', fileName);

      upload.setProperties({
        dataLoaded: data.loaded,
        dataTotal: data.total
      });
    },

    uploadFinished(s3Url, fileName){
      const uploads = this.get('fileUploads'),
        upload = uploads.findBy('file.name', fileName);

      if (this.attrs.uploadFinished) {
        this.attrs.uploadFinished(s3Url, upload.get('file'));
      }

      uploads.removeObject(upload);
    }
  }
});
