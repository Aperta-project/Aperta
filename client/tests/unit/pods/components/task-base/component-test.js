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
import { test, moduleForComponent } from 'ember-qunit';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';

moduleForComponent('task-base', 'Unit: components/task-base', {
  unit: true,

  beforeEach() {
    this.paper = Ember.Object.create({
      editable: true
    });

    this.currentUser = Ember.Object.create({
      siteAdmin: false
    });

    this.task = Ember.Object.create({
      isOnlyEditableIfPaperEditable: true,
      paper: this.paper,
      save: function() { }
    });

    this.register('service:can', FakeCanService);
    this.inject.service('can', { as: 'can' });

    Ember.run(()=> {
      this.subject().set('can', this.fakeCanService);
      this.subject().set('task', this.task);
      this.subject().set('currentUser', this.currentUser);
    });
  }
});

test('#isEditable: false the user does not have permission', function(assert) {
  Ember.run(()=> {
    this.subject().set('editAbility.can', false);
    assert.equal(this.subject().get('isEditable'), false);
  });
});

test('#isEditable: true when the task is not a metadata task', function(assert) {
  Ember.run(()=> {
    this.task.set('isOnlyEditableIfPaperEditable', false);
    assert.equal(this.subject().get('isEditable'), true);
  });
});

test('#toggleTaskCompletion marks the task as completed when there are no validation errors', function(assert) {
  let component = this.subject();
  component.validationErrorsPresent = () => { return false; };

  Ember.run(()=> {
    component.set('task.completed', false);
    // try to mark as incomplete
    component.actions.toggleTaskCompletion.apply(component);
  });
  assert.equal(component.get('task.completed'), true, 'task was successfuly completed');
});

test('#toggleTaskCompletion action skips validations when toggling a complete task back to incomplete', function(assert) {
  let component = this.subject();
  component.validationErrorsPresent = () => { return true; };

  Ember.run(()=> {
    component.set('task.completed', true);
    // try to mark as incomplete
    component.actions.toggleTaskCompletion.apply(component);
  });
  assert.equal(component.get('task.completed'), false, 'task was successfully toggled back to incomplete even when validation errors were present');
});

test('#toggleTaskCompletion does not leave skipValidations in a bad state when toggling a complete task back to incomplete', function(assert) {
  let component = this.subject();
  component.validationErrorsPresent = () => { return true; };

  // explicitly set skipValidations to false so we can ensure this is the
  // state it's set back to.
  component.set('skipValidations', false);

  // mark the task as complete so toggling it back to incomplete
  component.set('task.completed', true);

  Ember.run(()=> {
    component.actions.toggleTaskCompletion.apply(component);
  });
  assert.equal(component.get('skipValidations'), false, 'skipValidations was put back into its original state');
});
