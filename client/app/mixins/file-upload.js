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

export default Ember.Mixin.create({
  _initFileUpload: Ember.on('init', function() {
    return this.set('uploads', []);
  }),

  uploads: null,
  isUploading: Ember.computed.notEmpty('uploads'),

  needsSourcefile: Ember.computed('task.paper.journal.pdfAllowed', 'task.paper.fileType',
    function(){
      return (this.get('task.paper.journal.pdfAllowed') &&
             (this.get('task.paper.fileType') === 'pdf'));
    }
  ),

  unloadUploads(data, filename) {
    let uploads = this.get('uploads');
    let newUpload = uploads.findBy('file.name', filename);
    uploads.removeObject(newUpload);
  },

  uploadStarted(data, fileUploadXHR) {
    let file = data.files[0];
    let filename = file.name;

    this.get('uploads').pushObject(FileUpload.create({
      file: file,
      xhr: fileUploadXHR
    }));

    $(window).on('beforeunload.cancelUploads.' + filename, function() {
      return 'You are uploading, are you sure you want to abort uploading?';
    });
  },

  uploadProgress(data) {
    if (this.get('isDestroying') || !this.get('uploads')) { return; }
    let currentUpload = this.get('uploads').findBy('file', data.files[0]);
    if (!currentUpload) { return; }

    currentUpload.setProperties({
      dataLoaded: data.loaded,
      dataTotal: data.total
    });
  },

  uploadFinished(data, filename) {
    $(window).off('beforeunload.cancelUploads.' + filename);

    let key = Object.keys(data || {})[0];
    if ( (key && data[key]) || key && data[key] === [] ) {
      // TODO: DOM manipulation in mixin? This is used by controllers too
      $('.upload-preview-filename').text('Upload Complete!');
      Ember.run.later(this, ()=> {
         $('.progress').addClass('upload-complete');
      });
      Ember.run.later(this, ()=> {
        $('.progress').fadeOut(()=>{
          this.unloadUploads(data, filename);
        });
      }, 2000);
    } else {
      this.unloadUploads(data, filename);
    }

  },

  cancelUploads() {
    this.get('uploads').invoke('abort');
    this.set('uploads', []);
    return $(window).off('beforeunload.cancelUploads');
  },

  actions: {
    uploadProgress(data) { this.uploadProgress(data); },
    cancelUploads() { this.cancelUploads(); },
    uploadFinished(data, filename) { this.uploadFinished(data, filename); },
    uploadStarted(data, fileUploadXHR) { this.uploadStarted(data, fileUploadXHR); }
  }
});
