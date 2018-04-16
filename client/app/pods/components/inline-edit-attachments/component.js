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
import { task as concurrencyTask } from 'ember-concurrency';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  restless: Ember.inject.service(),
  editing: false,
  bodyPart: null,
  bodyPartType: Ember.computed.alias('bodyPart.type'),
  hasAttachments: Ember.computed.notEmpty('task.attachments'),
  showAttachments: false,
  showAttachmentsBlock: Ember.computed.or('hasAttachments', 'showAttachments'),

  attachmentsRequest: concurrencyTask(function * (path, method, s3Url, file) {
    const store = this.get('store');
    const restless = this.get('restless');
    let response = yield restless.ajaxPromise(method, path, {url: s3Url});
    response.attachment.filename = file.name;
    store.pushPayload(response);
  }),

  attachmentsPath: Ember.computed('task.id', function() {
    return `/api/tasks/${this.get('task.id')}/attachments`;
  }),

  actions: {
    updateAttachment(s3Url, file, attachment) {
      const path = `${this.get('attachmentsPath')}/${attachment.id}/update_attachment`;
      this.get('attachmentsRequest').perform(path, 'PUT', s3Url, file);
    },

    createAttachment(s3Url, file) {
      this.get('attachmentsRequest').perform(this.get('attachmentsPath'), 'POST', s3Url, file);
    },

    uploadFailed(reason) {
      throw new Ember.Error(`Upload from browser to s3 failed: ${reason}`);
    },

    addAttachmentsBlock() {
      this.set('showAttachments', true);
    }
  }
});
