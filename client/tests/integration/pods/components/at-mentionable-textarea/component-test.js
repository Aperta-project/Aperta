import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('at-mentionable-textarea', 'Integration | Component | at mentionable textarea', {
  integration: true
});

const charmander = Ember.Object.create({
  username: 'charmander',
  email: 'fire@oak.edu',
  name: 'Charmander Pokemon'
});

const bulbasaur = Ember.Object.create({
  username: 'bulbasaur',
  email: 'plant@oak.edu',
  name: 'Bulbasaur Pokemon'
});

const squirtle = Ember.Object.create({
  username: 'squirtle',
  email: 'water@oak.edu',
  name: 'Squirtle Pokemon (not Bulbasaur)'
});

test('it displays user names when a @ is typed', function(assert) {
  this.userList = [charmander, bulbasaur, squirtle];

  this.render(hbs`{{at-mentionable-textarea atMentionableUsers=userList}}`);
  const textarea = this.$('textarea');
  textarea.val('@');
  textarea.keyup();

  let atWhoItems = $('.atwho-container li');
  assert.equal(atWhoItems.length, 3);

  atWhoItems.each((i, item) => {
    const itemName = $(item).find('.at-who-name').text();
    const expectedItemName = this.userList[i].get('name');
    assert.equal(itemName, expectedItemName);
  });

  // now filter the list
  textarea.val('@char');
  textarea.keyup();

  atWhoItems = $('.atwho-container li');
  assert.equal(atWhoItems.length, 1, 'two users are filtered out');
  const firstName = atWhoItems.eq(0).find('.at-who-name').text();
  assert.equal(firstName, charmander.name);
});

test('it cleans up after itself', function(assert) {
  this.userList = [charmander, bulbasaur, squirtle];

  this.render(hbs`{{at-mentionable-textarea atMentionableUsers=userList}}`);
  assert.equal($('.atwho-container').length, 1);
  this.render(hbs``);
  assert.equal($('.atwho-container').length, 0);
});
