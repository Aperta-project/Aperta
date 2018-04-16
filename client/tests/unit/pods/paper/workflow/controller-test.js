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
import { test, moduleFor } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import wait from 'ember-test-helpers/wait';

moduleFor('controller:paper/workflow', 'Unit | Controller | paper workflow', {
  integration: true,

  beforeEach() {
    this.phase1 = Ember.Object.create({ position: 1 });
    this.phase2 = Ember.Object.create({ position: 2 });
    this.phase3 = Ember.Object.create({ position: 3 });
    this.phase4 = Ember.Object.create({ position: 4 });

    this.paper = Ember.Object.create({
      title: 'test paper',
      phases: []
    });

    this.registry.register(
      'service:pusher',
      Ember.Object.extend({ socketId: 'foo' })
    );
    $.mockjax.clear();

    $.mockjax({
      type: 'GET',
      url: '/api/journals',
      status: 200,
      responseText: { journals: [] }
    });
  },

  afterEach() {
    $.mockjax.clear();
  }
});

test('addTaskType will save a new task based on a PaperTaskType', function(
  assert
) {
  $.mockjax({
    type: 'POST',
    url: '/api/tasks',
    status: 201,
    responseText: { task: { id: 1, type: 'AdHocTask' } }
  });

  manualSetup(this.container);
  this.subject()
    .get('addTaskType')
    .perform(make('phase'), [make('paper-task-type', { type: 'AdHocTask', kind: 'AdHocTask' })]);
  return wait().then(() => {
    assert.ok(
      $.mockjax.mockedAjaxCalls().find(c => {
        return JSON.parse(c.data).task.type === 'AdHocTask';
      }),
      'sets the task type based on the PaperTaskType type'
    );
  });
});

test('addTaskType will save a new task based on a Card', function(assert) {
  $.mockjax({
    type: 'POST',
    url: '/api/tasks',
    status: 201,
    responseText: { task: { id: 1, type: 'CustomCardTask' } }
  });

  manualSetup(this.container);
  this.subject()
    .get('addTaskType')
    .perform(make('phase'), [
      make('card', { cardTaskType: { taskClass: 'CustomCardTask' } })
    ]);
  return wait().then(() => {
    assert.ok(
      $.mockjax.mockedAjaxCalls().find(c => {
        return JSON.parse(c.data).task.type === 'CustomCardTask';
      }),
      'sets the task type based on the CardTaskType taskClass'
    );
  });
});

test('#sortedPhases: phases are sorted by position', function(assert) {
  const paperWorkflowController = this.subject({ model: this.paper });
  paperWorkflowController.set('model.phases', [
    this.phase3,
    this.phase2,
    this.phase4
  ]);

  let sortedPositionArray = paperWorkflowController
    .get('sortedPhases')
    .mapBy('position')
    .toArray();

  assert.deepEqual(sortedPositionArray, [2, 3, 4]);

  paperWorkflowController.get('model.phases').pushObject(this.phase1);
  sortedPositionArray = paperWorkflowController
    .get('sortedPhases')
    .mapBy('position')
    .toArray();

  assert.deepEqual(sortedPositionArray, [1, 2, 3, 4]);
});

test('#updatePositions: phase positions are updated accordingly', function(
  assert
) {
  assert.equal(this.phase3.get('position'), 3);
  assert.equal(this.phase4.get('position'), 4);

  const paperWorkflowController = this.subject({ model: this.paper });

  paperWorkflowController.set('model.phases', [
    this.phase1,
    this.phase2,
    this.phase3,
    this.phase4
  ]);
  this.phase1.setProperties({ position: 3 });
  paperWorkflowController.updatePositions(this.phase1);

  assert.equal(this.phase3.get('position'), 4);
  assert.equal(this.phase4.get('position'), 5);
});
