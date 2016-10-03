import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import setupMockServer from '../helpers/mock-server';
import { make } from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import page from '../pages/ad-hoc-task';

let App = null;
let server = null;

const { mockFind } = TestHelper;

const paperTaskURL = function paperTaskURL(paper, task) {
  return '/papers/' + paper.get('id') + '/tasks/' + task.get('id');
};

module('Integration: AdHoc Card', {
  afterEach() {
    server.restore();
    Ember.run(function() { TestHelper.teardown(); });
    Ember.run(App, App.destroy);
  },

  beforeEach() {
    App      = startApp();
    server   = setupMockServer();

    server.respondWith('PUT', /\/api\/tasks\/\d+/, [
      204, {
        'Content-Type': 'application/json'
      }, JSON.stringify({})
    ]);

    server.respondWith('GET', '/api/tasks/1/nested_questions', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({nested_questions: []})
    ]);

    server.respondWith('GET', '/api/tasks/1/nested_question_answers', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({nested_question_answers: []})
    ]);

    server.respondWith('GET', '/api/journals', [200, { 'Content-Type': 'application/json' }, JSON.stringify({journals:[]})]);

    $.mockjax({
      url: '/api/countries',
      status: 200,
      responseText: []
    });
  }
});

test('Changing the title on an AdHoc Task', function(assert) {
  const paper = make('paper');
  const task  = make('task', { paper: paper, body: [], title: 'Custom title' });

  mockFind('paper').returns({ model: paper });
  mockFind('task').returns({ model: task });

  visit(paperTaskURL(paper, task));

  page.setTitle('Shazam!');

  andThen(function() {
    assert.equal(page.title, 'Shazam!', 'title is changed');
  });
});

test('AdHoc Task text block', function(assert) {
  let paper = make('paper');
  let task  = make('task', { paper: paper, body: [] });

  mockFind('paper').returns({ model: paper });
  mockFind('task').returns({ model: task });

  visit(paperTaskURL(paper, task));

  page.toolbar.addText();
  andThen(function() {
    page.textboxes(0).setText('New contenteditable, yahoo!');
  });

  andThen(function() {
    assert.textPresent('.inline-edit', 'yahoo');
  });

  page.textboxes(0).trash()
                   .confirmTrash();

  andThen(function() {
    assert.textNotPresent('.inline-edit', 'yahoo');
  });
});

test('AdHoc Task list block', function(assert) {
  const paper = make('paper');
  const task  = make('task', { paper: paper, body: [] });

  mockFind('paper').returns({ model: paper });
  mockFind('task').returns({ model: task });

  visit(paperTaskURL(paper, task));

  page.toolbar.open()
              .addCheckbox();

  andThen(function() {
    // PageObjects did not have support for contenteditable at the time of
    // writing. This needs to be an async function so it's wrapped in an
    // `andThen`.
    page.checkboxes(0).setLabel('checkbox list item');
  });
  page.checkboxes(0).save();

  andThen(function() {
    assert.equal(page.checkboxes(0).label, 'checkbox list item');
  });

  page.checkboxes(0).trash()
                    .confirmTrash();

  andThen(function() {
    assert.textNotPresent('.inline-edit', 'checkbox list item');
  });
});

test('AdHoc Task email block', function(assert) {
  const paper = make('paper');
  const task  = make('task', { paper: paper, body: [] });

  mockFind('paper').returns({ model: paper });
  mockFind('task').returns({ model: task });

  server.respondWith('PUT', /\/api\/tasks\/\d+\/send_message/, [
    204, {
      'Content-Type': 'application/json'
    }, JSON.stringify({})
  ]);

  visit(paperTaskURL(paper, task));

  page.toolbar.addEmail();

  page.emails(0).setSubject('Deep subject');


  andThen(function() {
    page.emails(0).setBody('Awesome email body!');
  });

  page.emails(0).save();

  andThen(function() {
    assert.textPresent('.inline-edit .item-subject', 'Deep');
    assert.textPresent('.inline-edit .item-text', 'Awesome');
  });

  page.emails(0).send().sendConfirm();

  andThen(function() {
    assert.elementFound('.bodypart-last-sent',
                        'The sent at time should appear');
    assert.elementFound('.bodypart-email-sent-overlay',
                        'The sent confirmation should appear');

    assert.ok(_.findWhere(server.requests, {
      method: 'PUT',
      url: '/api/tasks/1/send_message'
    }), 'It posts to the server');
  });
});
