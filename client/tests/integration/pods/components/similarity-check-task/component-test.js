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

import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';

var template = hbs`{{similarity-check-task task=task can=can container=container}}`;

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

var newTask = function(completed, paper, setting) {
  return {
    id: 2,
    title: 'Title and Abstract',
    type: 'TahiStandardTasks::TitleAndAbstractTask',
    completed: completed,
    isMetadataTask: false,
    isSubmissionTask: true,
    assignedToMe: true,
    paper: paper,
    currentSettingValue: setting || 'at_first_full_submission'
  };
};

var paperStub = {
  title: 'Paper title',
  abstract: 'Paper abstract',
  editable: true,
  manuallySimilarityChecked: false
};

var paperWithIncompleteCheck = {
  title: 'Paper title',
  abstract: 'Paper abstract',
  editable: true,
  manuallySimilarityChecked: false,
  latestVersionedText: {
    id: 1,
    similarityChecks: [{
      id: 1,
      versioned_text_id: 1,
      state: 'needs_upload',
      incomplete: true
    }]
  }
};

moduleForComponent(
  'similarity-check-task',
  'Integration | Components | Tasks | Similarity Check Task',
  {
    integration: true
  }
);

test('proper state for a non manually generated check', function(assert) {
  let task = newTask(false, paperStub);
  setupEditableTask(this, task);
  assert.elementFound('.similarity-check-task', 'the similarity check renders');
  assert.elementFound(
    '.automated-report-status',
    'it has an automated report status by default'
  );
  assert.elementFound('.generate-confirm', 'it has a generate report button');

  $('.generate-confirm').click();

  assert.elementFound('.confirm-container', 'it has a generate report button');
  assert.textPresent(
    '.confirm-container h4',
    'Manually generating the report will disable the automated similarity check for this manuscript',
    'has the correct text'
  );
});

test('proper state for a manually generated check', function(assert) {
  let paper = paperStub;
  paper.manuallySimilarityChecked = true;
  var task = newTask(false, paper);
  setupEditableTask(this, task);

  assert.elementFound('.similarity-check-task', 'the similarity check renders');
  assert.elementNotFound(
    '.automated-report-status',
    'it has an automated report status by default'
  );
  assert.elementFound('.generate-confirm', 'it has a generate report button');

  $('.generate-confirm').click();

  assert.elementFound('.confirm-container', 'it has a generate report button');
  assert.textPresent(
    '.confirm-container h4',
    `Are you sure?`,
    'has the correct text'
  );
});

test('proper state for auto check off via admin', function(assert) {
  let task = newTask(false, paperStub, 'off');
  setupEditableTask(this, task);
  assert.elementFound(
    '.auto-report-off',
    'does not have an auto report status block'
  );

  $('.generate-confirm').click();
  assert.elementFound('.confirm-container', 'it has a generate report button');
  assert.elementNotFound(
    '.auto-report-off',
    'report status disapears on confirm'
  );
});

test('Incomplete Similarity Check renders', function(assert) {
  let task = newTask(false, paperWithIncompleteCheck);
  setupEditableTask(this, task);
  assert.elementFound('.similarity-check');
});
