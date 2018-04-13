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

import DS from 'ember-data';
import Attachment from 'tahi/pods/attachment/model';
import { paperDownloadPath } from 'tahi/utils/api-path-helpers';
import Ember from 'ember';
export default Attachment.extend({
  previewSrc: DS.attr('string'),
  detailSrc: DS.attr('string'),
  task: null, //only used ephemerally
  fileDownloadUrl: Ember.computed('paper', function() {
    return paperDownloadPath({
      paperId: this.get('paper.id'),
      format: 'source'
    });
  }),
  s3Url: DS.attr('string'), // set by file uploader
  src: Ember.computed.or('s3Url', 'fileDownloadUrl'),
  cancelUploadPath() {
    return `/api/sourcefile_attachments/${this.get('id')}/cancel`;
  }
});
