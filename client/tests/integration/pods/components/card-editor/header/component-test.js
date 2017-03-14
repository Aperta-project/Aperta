import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('card-editor/header', 'Integration | Component | card editor | header', {
  integration: true
});

test('it renders the card name', function(assert) {
  const card = Ember.Object.create({ name: 'baby-o', journal: {id: 5}});
  this.set('card', card);

  this.render(hbs`{{card-editor/header card=card}}`);

  assert.textPresent('.card-editor-header h1', card.get('name'));
});

test('it renders a back button', function(assert) {
  const card = Ember.Object.create({ name: 'baby-o', journal: {id: 5}});
  this.set('card', card);

  this.render(hbs`{{card-editor/header card=card}}`);

  assert.textPresent('.card-editor-header-back', 'Card Catalogue');
});

test('it renders navigation', function(assert) {
  const card = Ember.Object.create({ name: 'baby-o', journal: {id: 5}});
  this.set('card', card);

  this.render(hbs`{{card-editor/header card=card}}`);

  assert.elementFound('.tab-bar');
});
