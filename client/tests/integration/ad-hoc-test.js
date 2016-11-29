import Ember from 'ember';
import { test } from 'qunit';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import startApp from 'tahi/tests/helpers/start-app';
import setupMockServer from 'tahi/tests/helpers/mock-server';
import { make } from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import page from 'tahi/tests/pages/ad-hoc-task';
import Factory from '../helpers/factory';

let server = null;

const { mockFind } = TestHelper;

const paperTaskURL = function paperTaskURL(paper, task) {
  return '/papers/' + paper.get('id') + '/tasks/' + task.get('id');
};

let journal;
moduleForAcceptance('Integration: AdHoc Card', {
  afterEach() {
    server.restore();
    Ember.run(function() { TestHelper.teardown(); });
  },

  beforeEach() {
    server   = setupMockServer();

    $.mockjax.clear();

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

    $.mockjax({
      url: '/api/countries',
      status: 200,
      responseText: []
    });
    journal = make('journal');
    mockFind('journal').returns({ model: journal});
    TestHelper.mockFindAll('journal').returns({models: [journal]});
  }
});

test('Changing the title on an AdHoc Task', function(assert) {
  const paper = make('paper');
  const task  = make('ad-hoc-task', { paper: paper, body: [], title: 'Custom title' });
  Factory.createPermission('AdHocTask', task.id, ['edit', 'view', 'manage']);

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
  let task  = make('ad-hoc-task', { paper: paper, body: [] });

  Factory.createPermission('AdHocTask', task.id, ['edit', 'view', 'manage']);

  mockFind('paper').returns({ model: paper });
  mockFind('task').returns({ model: task });

  visit(paperTaskURL(paper, task));

  page.toolbar.addText();
  page.textboxes(0).setText('New contenteditable, yahoo!');

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
  const task  = make('ad-hoc-task', { paper: paper, body: [] });
  Factory.createPermission('AdHocTask', task.id, ['edit', 'view', 'manage']);

  mockFind('paper').returns({ model: paper });
  mockFind('task').returns({ model: task });

  visit(paperTaskURL(paper, task));

  page.toolbar.open()
              .addCheckbox();

  page.checkboxes(0).labelText('checkbox list item');
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
  const task  = make('ad-hoc-task', { paper: paper, body: [] });
  Factory.createPermission('AdHocTask', task.id, ['edit', 'view', 'add_email_participants', 'manage']);

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

});
