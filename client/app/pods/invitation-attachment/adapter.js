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

import ApplicationAdapter from 'tahi/pods/application/adapter';
import DS from 'ember-data';
import Ember from 'ember';

function attachmentURL(id, modelName, snapshot) {
  return `/api/invitations/${snapshot.belongsTo('invitation').id}/attachments/${id}`;
}

export default ApplicationAdapter.extend(DS.BuildURLMixin, {
  urlForFindRecord: attachmentURL,

  urlForDeleteRecord: attachmentURL,

  urlForUpdateRecord: attachmentURL,

  findRecord(store, type, id, snapshot) {
    // this is for the case where a pusher message is received by window without the right data
    return snapshot.belongsTo('invitation') ? this._super(...arguments) : Ember.RSVP.reject();
  }
});
