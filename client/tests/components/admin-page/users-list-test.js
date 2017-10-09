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

  this.set('adminJournalUsers', Ember.A());
  this.set('roles', Ember.A());

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
