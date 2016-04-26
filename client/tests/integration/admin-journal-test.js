import Ember from 'ember';
import startApp from '../helpers/start-app';
import { test } from 'ember-qunit';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';

let app = null;
let server = null;
let journalId = null;

module('Integration: Admin Journal Test', {
  afterEach() {
    server.restore();
    return Ember.run(app, app.destroy);
  },

  beforeEach: function() {
    app = startApp();
    server = setupMockServer();
    let journal = Factory.createRecord('AdminJournal');
    journalId = journal.id;
    let adminRole = Factory.createJournalOldRole(journal, {
      name: 'Admin',
      kind: 'admin',
      can_administer_journal: true,
      can_view_assigned_manuscript_managers: false,
      can_view_all_manuscript_managers: true
    });
    let adminJournalPayload = Factory.createPayload('adminJournal');
    adminJournalPayload.addRecords([journal, adminRole]);
    let stubbedAdminJournalUserResponse = {
      user_roles: [],
      admin_journal_users: []
    };

    server.respondWith('GET', '/api/admin/journals/authorization', [
      204, {
        'Content-Type': 'application/html'
      }, ''
    ]);
    server.respondWith('PUT', '/api/admin/journals/' + journalId, [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(adminJournalPayload.toJSON())
    ]);
    server.respondWith('GET', '/api/admin/journals/' + journalId, [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(adminJournalPayload)
    ]);

    let url = '/api/admin/journal_users?journal_id=' + journalId;
    server.respondWith('GET', url, [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(stubbedAdminJournalUserResponse)
    ]);

    server.respondWith('GET', "/api/journals", [200, { 'Content-Type': 'application/json' }, JSON.stringify({journals:[]})]);
  }
});

test('saving doi info will send a put request to the admin journal controller', function(assert) {
  let adminPage = '/admin/journals/' + journalId;

  visit(adminPage).then(function() {
    click('.admin-doi-settings-edit-button');
    fillIn('.admin-doi-setting-section .doi_publisher_prefix', 'PPREFIX');
    fillIn('.admin-doi-setting-section .doi_journal_prefix', 'JPREFIX');
    fillIn('.admin-doi-setting-section .first_doi_number', '00001');
    click('.admin-doi-setting-section button');
  });

  andThen(function() {
    return assert.ok(_.findWhere(server.requests, {
      method: 'PUT',
      url: '/api' + adminPage
    }));
  });
});

test('saving invalid doi info will display an error', function(assert) {
  server.respondWith('PUT', '/api/admin/journals/' + journalId, [
    422, {
      'Content-Type': 'application/json'
    }, JSON.stringify({
      errors: {
        doi: ['Invalid']
      }
    })
  ]);

  let adminPage = '/admin/journals/' + journalId;
  visit(adminPage).then(function() {
    click('.admin-doi-settings-edit-button');
    fillIn('.admin-doi-setting-section .doi_publisher_prefix', 'PPREFIX');
    fillIn('.admin-doi-setting-section .doi_journal_prefix', 'a/b');
    fillIn('.admin-doi-setting-section .first_doi_number', '00001');
    return click('.admin-doi-setting-section button');
  });

  andThen(function() {
    assert.ok(
      find('.admin-doi-setting-section .error-message').text().match(/Invalid/)
    );
  });
});
