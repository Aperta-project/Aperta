import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';

moduleForComponent('comment-board-form', 'Unit | Component | comment board form', {
  unit: true
});

const charmander = {
  username: 'charmander',
  email: 'fire@oak.edu',
  name: 'Charmander Pokémon'
};

const bulbasaur = Ember.Object.create({
  username: 'bulbasaur',
  email: 'plant@oak.edu',
  name: 'Bulbasaur Pokemon'
});

test('#atMentionableUsers does not have duplicates', function(assert) {
  const userA = Ember.Object.create(charmander);
  const userB = Ember.Object.create(charmander);

  const component = this.subject({
    participants: [userA],
    atMentionableStaffUsers: [userB]
  });

  assert.equal(component.get('atMentionableUsers.length'), 1,
               'it should contain no duplicates');
});

test('#atMentionableUsers does not have the current user', function(assert) {
  const otherUser = Ember.Object.create(charmander);
  const currentUser = Ember.Object.create(bulbasaur);

  const component = this.subject({
    participants: [otherUser, currentUser],
    currentUser
  });

  assert.deepEqual(component.get('atMentionableUsers'), [otherUser]);
});

test('#atMentionableUsers updates when a participant is removed',
function(assert) {
  const user = Ember.Object.create(charmander);
  const users = Ember.A([user]);

  const component = this.subject({
    participants: users
  });

  assert.deepEqual(component.get('atMentionableUsers'), [user]);
  users.popObject();
  assert.deepEqual(component.get('atMentionableUsers'), []);
});

