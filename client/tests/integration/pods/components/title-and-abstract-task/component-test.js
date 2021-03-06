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

import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
// Pretend like you're in client/tests
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import wait from 'ember-test-helpers/wait';
import {findEditor} from 'tahi/tests/helpers/rich-text-editor-helpers';

moduleForComponent(
  'title-and-abstract-task',
  'Integration | Components | Tasks | Title and Abstract', {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
    }
  });

test('User can edit the title and abstract', function(assert) {
  var task = newTask(false, true);
  setupEditableTask(this, task);
  let title = findEditor('article-title-input');
  let abstract = findEditor('article-abstract-input');
  assert.ok(title);
  assert.ok(abstract);
});

test('Title/abstract not editable when task is complete', function(assert) {
  var task = newTask(true, true);
  setupEditableTask(this, task);
  let title = findEditor('article-title-input');
  let abstract = findEditor('article-abstract-input');
  assert.ok(!title);
  assert.ok(!abstract);
});

test('Title/abstract not editable when task is complete and paper not editable', function(assert) {
  var task = newTask(true, false);
  setupEditableTask(this, task);
  let title = findEditor('article-title-input');
  let abstract = findEditor('article-abstract-input');
  assert.ok(!title);
  assert.ok(!abstract);
});

test('Title and abstract needs to be present', function(assert) {
  var task = newTask(false, true);
  setupEditableTask(this, task);

  let done = assert.async();
  wait().then(() => {
    assert.textNotPresent('.task-completed', 'Make changes to this task');
    done();
  });
});

test('Show error when Title and abstract are not present', function(assert) {
  var task = newTask(false, true);
  task.paperTitle = null;
  task.paperAbstract = null;
  setupEditableTask(this, task);

  this.$('.task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.textPresent('.error-message', 'Please fix all errors');
    done();
  });
});

var newTask = function(completed, paperEditable) {
  return {
    id: 2,
    title: 'Title and Abstract',
    type: 'TahiStandardTasks::TitleAndAbstractTask',
    completed: completed,
    completedProxy: completed,
    isMetadataTask: false,
    isSubmissionTask: true,
    assignedToMe: false,
    paperTitle: 'Paper title',
    paperAbstract: 'Paper abstract',
    paper: {
      title: 'Paper title',
      abstract: 'Paper abstract',
      editable: paperEditable
    }
  };
};

var template = hbs`{{title-and-abstract-task task=task can=can container=container}}`;

var setupEditableTask = function(context, task) {
  task = task || newTask();
  var can = FakeCanService.create();
  can.allowPermission('edit', task);

  context.setProperties({
    can: can,
    task: task
  });

  context.render(template);
};
