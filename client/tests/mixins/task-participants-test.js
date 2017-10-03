import { module, test } from 'qunit';
import Ember from 'ember';
import TaskParticipantsMixin from 'tahi/mixins/components/task-participants';

const FakeObject = Ember.Object.extend(TaskParticipantsMixin);

module('Unit | Mixin | Task Participants ', {
  beforeEach() {
    this.object = FakeObject.create();
  }
});

test('#assignedUser it returns an array with a single user when assigned', function(assert) {
  let user = Ember.Object.create({id: 1});
  this.object.set('task', Ember.Object.create({assignedUser: user}));
  this.object.get('saveAssignedUser', user);

  assert.equal(this.object.get('assignedUser').length, 1);
  assert.equal(this.object.get('assignedUser')[0], user);
});

test('#assignedUser it returns an empty array when user is not yet assigned', function(assert) {
  let user = Ember.Object.create();
  this.object.set('task', Ember.Object.create({assignedUser: user}));

  assert.equal(this.object.get('assignedUser').length, 0);
});
