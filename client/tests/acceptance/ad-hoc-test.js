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
import { test } from 'qunit';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import setupMockServer from 'tahi/tests/helpers/mock-server';
import { make, mockFindRecord, mockFindAll } from 'ember-data-factory-guy';
import * as TestHelper from 'ember-data-factory-guy';
import page from 'tahi/tests/pages/ad-hoc-task';
import Factory from 'tahi/tests/helpers/factory';

let server = null;

const paperTaskURL = function paperTaskURL(paper, task) {
  return '/papers/' + paper.get('shortDoi') + '/tasks/' + task.get('id');
};

moduleForAcceptance('Integration: AdHoc Card', {
  afterEach() {
    server.restore();
  },

  beforeEach() {
    server   = setupMockServer();

    $.mockjax({type: 'PUT',
      url: /\/api\/tasks\/\d+/,
      status: 204
    });

    $.mockjax({type: 'GET',
      url: '/api/tasks/1/nested_questions',
      status: 200,
      responseText: {nested_questions: []}
    });

    $.mockjax({type: 'GET',
      url: '/api/tasks/1/nested_question_answers',
      status: 200,
      responseText: {nested_question_answers: []}
    });

    $.mockjax({
      url: '/api/countries',
      status: 200,
      responseText: []
    });
    let journal = make('journal');
    mockFindRecord('journal').returns({ model: journal});
    mockFindAll('journal').returns({models: [journal]});
  }
});

test('Changing the title on an AdHoc Task', function(assert) {
  const paper = make('paper');
  const task  = make('ad-hoc-task', { paper: paper, body: [], title: 'Custom title' });
  Factory.createPermission('AdHocTask', task.id, ['edit', 'view', 'manage']);

  TestHelper.mockPaperQuery(paper);
  mockFindRecord('task').returns({ json: {task: {type: 'ad-hoc-task', id: task.id}} });
  visit(paperTaskURL(paper, task));

  page.setTitle('Shazam!');

  andThen(function() {
    assert.equal(page.title, 'Shazam!', 'title is changed');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
  });
});

test('AdHoc Task text block', function(assert) {
  let paper = make('paper');
  let task  = make('ad-hoc-task', { paper: paper, body: [] });

  Factory.createPermission('AdHocTask', task.id, ['edit', 'view', 'manage']);

  TestHelper.mockPaperQuery(paper);
  mockFindRecord('task').returns({ json: {task: {type: 'ad-hoc-task', id: task.id}} });

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

  TestHelper.mockPaperQuery(paper);
  mockFindRecord('task').returns({ json: {task: {type: 'ad-hoc-task', id: task.id}} });

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

  TestHelper.mockPaperQuery(paper);
  mockFindRecord('task').returns({ json: {task: {type: 'ad-hoc-task', id: task.id}} });

  $.mockjax({type: 'PUT',
    url: /\/api\/tasks\/\d+\/send_message/,
    status: 204
  });

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
