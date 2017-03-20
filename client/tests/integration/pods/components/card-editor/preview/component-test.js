import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('card-editor/preview', 'Integration | Component | card editor | preview', {
  integration: true
});

test('it renders a preview (defaults wide)', function(assert) {
  const card = Ember.Object.create({ name: 'Fig' });
  this.set('card', card);
  this.render(hbs`{{card-editor/preview card=card}}`);

  assert.elementFound('.card-editor-preview-overlay');
  assert.elementNotFound('.card-editor-preview-sidebar');
});

test('it renders a preview (narrow when sidebar-preview)', function(assert) {
  const card = Ember.Object.create({ name: 'Fig' });
  this.set('card', card);
  this.render(hbs`{{card-editor/preview card=card sidebar=true}}`);

  assert.elementFound('.card-editor-preview-sidebar');
  assert.elementNotFound('.card-editor-preview-overlay');
});

test('it has buttons for toggling width', function(assert) {
  const card = Ember.Object.create({ name: 'Fig' });
  this.set('card', card);
  this.render(hbs`{{card-editor/preview card=card}}`);

  assert.elementFound('.card-editor-preview-overlay');
  $('.card-editor-sidebar-button').click();
  assert.elementFound('.card-editor-preview-sidebar');
  $('.card-editor-full-screen-button').click();
  assert.elementFound('.card-editor-preview-overlay');
});
