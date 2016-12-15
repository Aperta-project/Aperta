import Ember from 'ember';
import { test, moduleForComponent } from 'ember-qunit';
import FakeCanService from '../helpers/fake-can-service';

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
