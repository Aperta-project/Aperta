import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import setupMockServer from '../helpers/mock-server';
import { paperWithTask } from '../helpers/setups';
import Factory from '../helpers/factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

let App = null;
let server = null;
let fakeUser = null;
let currentPaper = null;

module('Integration: Super AdHoc Card', {
  afterEach() {
    server.restore();
    Ember.run(function() { TestHelper.teardown(); });
    Ember.run(App, App.destroy);
  },

  beforeEach() {
    App      = startApp();
    server   = setupMockServer();
    fakeUser = window.currentUserData.user;

    TestHelper.handleFindAll('discussion-topic', 1);

    let records = paperWithTask('Task', {
      id: 1,
      title: 'Super Ad-Hoc'
    });

    currentPaper = records[0];

    let paperPayload = Factory.createPayload('paper');
    paperPayload.addRecords(records.concat([fakeUser]));

    let paperResponse = paperPayload.toJSON();
    let collaborators = [
      {
        id: '35',
        full_name: 'Aaron Baker',
        info: 'testroles2, collaborator'
      }
    ];

    server.respondWith('GET', '/api/dashboards', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({
        dashboards: []
      })
    ]);

    server.respondWith('GET', '/api/papers/' + currentPaper.id, [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(paperResponse)
    ]);

    server.respondWith('PUT', /\/api\/tasks\/\d+/, [
      204, {
        'Content-Type': 'application/json'
      }, JSON.stringify({})
    ]);

    server.respondWith('GET', "/api/tasks/1/nested_questions", [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify({nested_questions: []})
    ]);

    server.respondWith('GET', "/api/tasks/1/nested_question_answers", [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify({nested_question_answers: []})
    ]);


    let collabsURL = '/api/filtered_users/collaborators/' + currentPaper.id;
    server.respondWith('GET', collabsURL , [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(collaborators)
    ]);

    let nonPartURL = /\/api\/filtered_users\/non_participants\/\d+\/\w+/;
    server.respondWith('GET', nonPartURL, [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify([])
    ]);

    $.mockjax({
      url: '/api/countries',
      status: 200,
      responseText: []
    });
  }
});

test('Changing the title on an AdHoc Task', function(assert) {
  visit('/papers/' + currentPaper.id + '/tasks/1');
  click('h1.inline-edit .fa-pencil');
  fillIn('.large-edit input[name=title]', 'Shazam!');
  click('.large-edit .button--green:contains("Save")');

  andThen(function() {
    assert.equal(
      find('h1.inline-edit:contains("Shazam!")').length, 1, 'title is changed'
    );
  });
});

test('Adding a text block to an AdHoc Task', function(assert) {
  visit('/papers/' + currentPaper.id + '/tasks/1');
  click('.adhoc-content-toolbar .fa-plus');
  click('.adhoc-content-toolbar .adhoc-toolbar-item--text');

  andThen(function() {
    Ember.$('.inline-edit-form div[contenteditable]')
         .html('New contenteditable, yahoo!')
         .trigger('keyup');
    click('.task-body .inline-edit-body-part .button--green:contains("Save")');
  });

  andThen(function() {
    assert.textPresent('.inline-edit', 'yahoo');
    click('.inline-edit-body-part .fa-trash');
  });

  andThen(function() {
    assert.textPresent('.inline-edit-body-part', 'Are you sure?');
    click('.inline-edit-body-part .delete-button');
  });

  andThen(function() {
    assert.textNotPresent('.inline-edit', 'yahoo');
  });
});

test('Adding and removing a checkbox item to an AdHoc Task', function(assert) {
  visit('/papers/' + currentPaper.id + '/tasks/1');
  click('.adhoc-content-toolbar .fa-plus');
  click('.adhoc-content-toolbar .adhoc-toolbar-item--list');

  andThen(function() {
    assert.equal(
      find('.inline-edit-form .item-remove').length,
      1,
      'item remove button visible'
    );

    Ember.$('.inline-edit-form label[contenteditable]')
         .html('Here is a checkbox list item')
         .trigger('keyup');

    click('.task-body .inline-edit-body-part .button--green:contains("Save")');
  });

  andThen(function() {
    assert.textPresent('.inline-edit', 'checkbox list item');
    assert.equal(
      find('.inline-edit input[type=checkbox]').length,
      1,
      'checkbox item is visble'
    );
    click('.inline-edit-body-part .fa-trash');
  });

  andThen(function() {
    assert.textPresent('.inline-edit-body-part', 'Are you sure?');
    click('.inline-edit-body-part .delete-button');
  });

  andThen(function() {
    assert.textNotPresent('.inline-edit', 'checkbox list item');
  });
});

test('Adding an email block to an AdHoc Task', function(assert) {
  visit('/papers/' + currentPaper.id + '/tasks/1');
  click('.adhoc-content-toolbar .fa-plus');
  click('.adhoc-content-toolbar .adhoc-toolbar-item--email');

  fillIn(
    '.inline-edit-form input[placeholder="Enter a subject"]', 'Deep subject'
  );

  andThen(function() {
    Ember.$('.inline-edit-form div[contenteditable]')
         .html('Awesome email body!')
         .trigger('keyup');
    click('.task-body .inline-edit-body-part .button--green:contains("Save")');
  });

  andThen(function() {
    assert.textPresent('.inline-edit .item-subject', 'Deep');
    assert.textPresent('.inline-edit .item-text', 'Awesome');
  });
});

test('User can send an email from an adhoc card', function(assert) {
  server.respondWith('PUT', /\/api\/tasks\/\d+\/send_message/, [
    204, {
      'Content-Type': 'application/json'
    }, JSON.stringify({})
  ]);

  visit('/papers/' + currentPaper.id + '/tasks/1');
  click('.adhoc-content-toolbar .fa-plus');
  click('.adhoc-content-toolbar .adhoc-toolbar-item--email');

  fillIn(
    '.inline-edit-form input[placeholder="Enter a subject"]', 'Deep subject'
  );

  andThen(function() {
    Ember.$('.inline-edit-form div[contenteditable]')
         .html('Awesome email body!')
         .trigger('keyup');
    click('.task-body .inline-edit-body-part .button--green:contains("Save")');
  });

  click('.task-body .email-send-participants');
  click('.send-email-action');

  andThen(function() {
    assert.ok(
      find('.bodypart-last-sent').length,
      'The sent at time should appear'
    );

    assert.ok(
      find('.bodypart-email-sent-overlay').length,
      'The sent confirmation should appear'
    );

    assert.ok(_.findWhere(server.requests, {
      method: 'PUT',
      url: '/api/tasks/1/send_message'
    }), 'It posts to the server');
  });
});
