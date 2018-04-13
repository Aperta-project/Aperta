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
import fontAwesomeFiletypeClass from 'tahi/lib/font-awesome-fyletype-class';

export default Ember.Component.extend({
  isProcessing: Ember.computed.equal('attachment.status', 'processing'),

  fileTypeClass: Ember.computed('attachment.file', function(){
    return fontAwesomeFiletypeClass(this.get('attachment.file'));
  }),

  actions: {
    triggerFileSelection() {
      this.$().find('input.update-attachment').click();
      return false;
    },

    uploadFinished(s3Url, file){
      this.attrs.uploadFinished(s3Url, file, this.get('attachment'));
    },

    deleteFile() {
      if (this.attrs.deleteFile) {
        this.attrs.deleteFile(this.get('attachment'));
      }
    },

    cancelUpload() {
      this.set('isCanceled', true);
      this.get('cancelUpload')(this.get('attachment'));
    }
  }
});
