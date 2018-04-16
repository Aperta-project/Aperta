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

export default Ember.Component.extend({
  classNameBindings: [':_uploading', 'error:alert'],

  file: Ember.computed.alias('upload.file'),
  filename: Ember.computed.alias('file.name'),
  error: null,

  /**
   * @property upload
   * @type {FileUpload} Ember.Object
   * @default null
   * @required
   */
  upload: null,

  preview: Ember.computed('file.preview', function() {
    let preview = this.get('file.preview');
    return preview !== null ? preview.toDataURL() : void 0;
  }),

  progress: Ember.computed('upload.dataLoaded', 'upload.dataTotal', function() {
    return Math.round(this.get('upload.dataLoaded') * 100 / this.get('upload.dataTotal'));
  }),

  progressBarStyle: Ember.computed('progress', function() {
    return Ember.String.htmlSafe('width: ' + (this.get('progress')) + '%;');
  })
});
