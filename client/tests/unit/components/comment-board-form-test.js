import { moduleForComponent, test } from 'ember-qunit';

moduleForComponent('comment-board-form', 'Unit | Component | comment board form', {
  unit: true
});

const charmander = {
  username: 'charmander',
  email: 'fire@oak.edu',
  name: 'Charmander Pokémon'
};

test('#atMentionableUsers', function(assert) {
  const userA = Ember.Object.create(charmander);
  const userB = Ember.Object.create(charmander);

  const component = this.subject({
    participants: [userA],
    atMentionableStaffUsers: [userB]
  });

  assert.equal(component.get('atMentionableUsers.length'), 1,
               'it should contain no duplicates');
});
