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
import startApp from 'tahi/tests/helpers/start-app';
import { test, moduleFor } from 'ember-qunit';

moduleFor(
  'controller:admin/mmt/journal/manuscript-manager-template/edit',
  'ManuscriptManagerTemplateEditController', {

  beforeEach() {
    startApp();
    Ember.run(() => {
      this.ctrl = this.subject();
      this.store = getStore();
      this.phase = this.store.createRecord('phaseTemplate', {
        name: 'First Phase'
      });

      this.task1 = this.store.createRecord('taskTemplate', {
        title: 'ATask',
        phaseTemplate: this.phase
      });

      this.task2 = this.store.createRecord('taskTemplate', {
        title: 'BTask',
        phaseTemplate: this.phase
      });

      this.template = this.store.createRecord('manuscriptManagerTemplate', {
        name: 'A name',
        paper_type: 'A type',
        phases: [this.phase]
      });

      this.ctrl.setProperties({
        model: this.template,
        store: this.store
      });
    });
  }
});

test('#rollbackPhase sets the given old name on the given phase', function(assert) {
  const phase = Ember.Object.create({
    name: 'Captain Picard'
  });
  this.ctrl.send('rollbackPhase', phase, 'Captain Kirk');
  return assert.equal(phase.get('name'), 'Captain Kirk');
});

test('#addPhase adds a phase at a specified index', function(assert) {
  return Ember.run(() => {
    this.ctrl.send('addPhase', 0);
    assert.equal(
      this.ctrl.get('sortedPhaseTemplates.firstObject.name'),
      'New Phase'
    );
  });
});
