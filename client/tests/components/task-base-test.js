import Ember from 'ember';
import { test, moduleForComponent } from 'ember-qunit';
import FakeCanService from '../helpers/fake-can-service';

moduleForComponent('task-base', 'TaskBase', {
  unit: true,

  beforeEach() {
    this.paper = Ember.Object.create({
      editable: true
    });

    this.currentUser = Ember.Object.create({
      siteAdmin: false
    });

    this.task = Ember.Object.create({
      isSubmissionTask: true,
      paper: this.paper
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
    this.task.set('isSubmissionTask', false);
    assert.equal(this.subject().get('isEditable'), true);
  });
});

test('#isEditable: true when paper is editable and task is a metadata task', function(assert) {
  Ember.run(()=> {
    this.paper.set('editable', true);
    assert.equal(this.subject().get('isEditable'), true);
  });
});

test('#isEditable: false when the paper is not editable and the task is a metadata task', function(assert) {
  Ember.run(()=> {
    this.paper.set('editable', false);
    this.task.set('isSubmissionTask', true);
    assert.equal(this.subject().get('isEditable'), false);
  });
});
