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
import { module, test } from 'ember-qunit';
import startApp from 'tahi/tests/helpers/start-app';
import FactoryGuy from 'ember-data-factory-guy';

var app = null;
module('Unit: Task Model', {
  beforeEach: function() {
    app = startApp();
  },
  afterEach: function() {
    Ember.run(app, app.destroy);
  }
});

test("findQuestion finds and returns the first nestedQuestion when the given path matches its ident exactly", function(assert) {
  let store = getStore();
  let task, nestedQuestion;
  Ember.run(() => {
    task = store.createRecord('task');
    nestedQuestion = store.createRecord('nested-question', {
      ident: "foobar",
      task: task
    });
    task.get('nestedQuestions').addObject(nestedQuestion);
    return task;
  });
  assert.equal(task.findQuestion('foobar'), nestedQuestion);
});

test("findQuestion returns null when it doesn't have a nestedQuestion whose ident that matches the given path", function(assert) {
  let store = getStore();
  let task, nestedQuestion;
  Ember.run(() => {
    task = store.createRecord('task');
    nestedQuestion = store.createRecord('nested-question', {
      ident: "foobar",
      task: task
    });
    task.get('nestedQuestions').addObject(nestedQuestion);
    return task;
  });
  assert.equal(task.findQuestion('bazbaz'), null);
});

test("permissionState delegates permission state to paper", function(assert) {
  let store = getStore();
  let paper, task;
  Ember.run(() => {
    paper = store.createRecord('paper', {
      permissionState: 'submitted'
    });
    task = store.createRecord('task', {
      paper: paper
    });
  });
  assert.equal(task.get('permissionState'), 'submitted');
});

test('isSidebarTask() returns true if designated as a custom card task', function(assert) {
  let task = FactoryGuy.make('custom-card-task', {
    isWorkflowOnlyTask: false
  });

  assert.equal(task.get('isSidebarTask'), true);
});

test('isSidebarTask() returns false if designated as a custom card, workflow only task', function(assert) {
  let task = FactoryGuy.make('custom-card-task', {
    isWorkflowOnlyTask: true });

  assert.equal(task.get('isSidebarTask'), false);
});

test('isSidebarTask() returns false if designated as a legacy, workflow only task', function(assert) {
  let task = FactoryGuy.make('authors-task', {
    isWorkflowOnlyTask: true });

  assert.equal(task.get('isSidebarTask'), false);
});

test('isSidebarTask() returns true if legacy task, assigned to user', function(assert) {
  let task = FactoryGuy.make('authors-task', {
    isWorkflowOnlyTask: false,
    assignedToMe: true
  });

  assert.equal(task.get('isSidebarTask'), true);
});

test('isSidebarTask() returns true if legacy, submission task', function(assert) {
  let task = FactoryGuy.make('authors-task', {
    isWorkflowOnlyTask: false,
    assignedToMe: false,
    isSubmissionTask: true
  });

  assert.equal(task.get('isSidebarTask'), true);
});
