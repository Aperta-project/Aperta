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

import {
  moduleForComponent,
  test
} from 'ember-qunit';

import { make } from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';
import wait from 'ember-test-helpers/wait';
import Ember from 'ember';

moduleForComponent('review-status', 'Integration | Component | Admin Page | Users List', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    this.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
    this.set('journal', make('admin-journal'));
  }
});

test('Searches are scoped on Journal', function (assert) {
  $.mockjax({url: '/api/admin/journal_users', type: 'GET', status: 200, responseText: '{}'});

  this.set('adminJournalUsers', []);
  this.set('roles', []);

  this.render(hbs`{{admin-page/users-list adminJournalUsers=adminJournalUsers journal=journal roles=roles }}`);

  this.$('.admin-user-search input').val('author').change();
  this.$('.admin-user-search button').click();

  return wait().then(() => {
    let mockedRequest = $.mockjax.mockedAjaxCalls()[0];
    assert.equal(mockedRequest.url, '/api/admin/journal_users');
    assert.equal(mockedRequest.data.journal_id, this.get('journal.id'));
    assert.equal(mockedRequest.data.query, 'author');
  });
});
