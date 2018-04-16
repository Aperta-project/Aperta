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

import { module, test } from 'qunit';
import Ember from 'ember';
import FileUploadMixin from 'tahi/mixins/file-upload';

module('FileUploadMixin', {
  beforeEach() {
    const ExtendedObject = Ember.Object.extend(FileUploadMixin, {});
    this.cntrl = ExtendedObject.create();
  }
});

test('with data key delays progress bar', function(assert) {
  this.cntrl.uploads = [{file: {name: 'yeti.jpg'}}];
  let data = { figure: 'some figure' };
  this.cntrl.uploadFinished(data, 'yeti.jpg');
  let uploads = this.cntrl.uploads;
  assert.equal(uploads.length, 1);
});


test('without data keys skips progress bar', function(assert) {
  this.cntrl.uploads = [{file: {name: 'yeti.jpg'}}];
  let data = {};
  this.cntrl.uploadFinished(data, 'yeti.jpg');
  let uploads = this.cntrl.uploads;
  assert.equal(uploads.length, 0);
});
