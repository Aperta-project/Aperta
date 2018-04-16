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

import { test } from 'ember-qunit';
import {
  paperWithTask,
  addNestedQuestionToTask
} from 'tahi/tests/helpers/setups';
import setupMockServer from 'tahi/tests/helpers/mock-server';
import Factory from 'tahi/tests/helpers/factory';
import { mockFindAll } from 'ember-data-factory-guy';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
var currentPaper, fakeUser, server;
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';

server = null;

fakeUser = null;

currentPaper = null;

moduleForAcceptance('Integration: PaperIndex', {
  beforeEach: function() {
    var figureTask,
      figureTaskId,
      figureTaskResponse,
      nestedQuestion,
      paperPayload,
      paperResponse,
      records,
      taskPayload,
      tasksPayload;
    server = setupMockServer();
    registerCustomAssertions();
    fakeUser = window.currentUserData.user;
    mockFindAll('discussion-topic', 1);
    figureTaskId = 94139;
    records = paperWithTask('FigureTask', {
      id: figureTaskId
    });

    [currentPaper, figureTask] = records;

    nestedQuestion = Factory.createRecord('NestedQuestion', {
      ident: 'figures--complies'
    });
    addNestedQuestionToTask(nestedQuestion, figureTask);
    paperPayload = Factory.createPayload('paper');
    paperPayload.addRecords(records.concat([fakeUser]));
    paperResponse = paperPayload.toJSON();
    paperResponse.paper.gradual_engagement = true;
    tasksPayload = Factory.createPayload('tasks');
    tasksPayload.addRecords([figureTask]);
    taskPayload = Factory.createPayload('task');
    taskPayload.addRecords([
      figureTask,
      currentPaper,
      fakeUser,
      nestedQuestion
    ]);
    figureTaskResponse = taskPayload.toJSON();
    delete paperResponse.paper.tasks;
    paperResponse.paper.links = {
      tasks: `/api/papers/${currentPaper.shortDoi}/tasks`
    };
    server.respondWith('GET', '/api/papers/' + currentPaper.shortDoi, [
      200,
      {
        'Content-Type': 'application/json'
      },
      JSON.stringify(paperResponse)
    ]);
    server.respondWith(
      'GET',
      '/api/papers/' + currentPaper.shortDoi + '/tasks',
      [
        200,
        {
          'Content-Type': 'application/json'
        },
        JSON.stringify(tasksPayload.toJSON())
      ]
    );
    server.respondWith('GET', '/api/tasks/' + figureTaskId, [
      200,
      {
        'Content-Type': 'application/json'
      },
      JSON.stringify(figureTaskResponse)
    ]);
    server.respondWith('GET', /\/api\/filtered_users\/users\/\d+/, [
      200,
      {
        'Content-Type': 'application/json'
      },
      JSON.stringify([])
    ]);
    mockFindAll('journal');
  }
});

test('visiting /paper: Author completes all metadata cards', function(assert) {
  assert.expect(3);
  visit('/papers/' + currentPaper.shortDoi)
    .then(function() {
      return assert.ok(
        !find('#paper-container.sidebar-empty').length,
        'The sidebar should NOT be hidden'
      );
    })
    .then(function() {
      const submitButton = find('button:contains("Submit")');
      return assert.ok(!submitButton.length, 'Submit is disabled');
    })
    .then(function() {
      const ref = find('#paper-submission-tasks .card');
      let results = [];
      let i, len;
      for (i = 0, len = ref.length; i < len; i++) {
        let card = ref[i];
        click(card);
        click('.task-completed');
        results.push(click('.overlay-close-button:first'));
      }
      return results;
    });
  andThen(function() {
    const submitButton = find('button:contains("Submit")');
    assert.notOk(
      submitButton.hasClass('button--disabled'),
      'Submit is enabled'
    );
  });
});

test('visiting /paper: Gradual Engagement banner visible', function(assert) {
  visit(
    '/papers/' + currentPaper.shortDoi + '?firstView=true'
  ).then(function() {
    assert.ok(find('#submission-process').length, 'The banner is visible');
  });

  click('#sp-close');

  andThen(function() {
    assert.ok(!find('#submission-process').length, 'The banner is not visible');
  });
});

test('visiting /paper: Paper displays for a real url', function(assert) {
  visit(
    '/papers/' + currentPaper.shortDoi + '?firstView=true'
  ).then(function() {
    assert.ok(
      currentRouteName() === 'paper.index.index',
      'The shortDoi path is not pointing to the paper.index.index Ember route'
    );
    assert.ok(
      find('.manuscript-pane').length,
      'The manuscript pane is not visible'
    );
  });
});

test('visiting /paper: Redirects to dashboard for malformed url', function(
  assert
) {
  visit('/papers/' + currentPaper.shortDoi + 'blah').then(function() {
    assert.ok(
      currentRouteName() ==='dashboard.loading',
      'The dashboard welcome message is not visible'
    );
  });
});
