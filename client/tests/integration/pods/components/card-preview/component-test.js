import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('card-preview', 'Integration | Component | Card Preview', {
  integration: true
});


test('it shows a settings icon if task has settings enabled', function(assert) {
  const taskTemplate = Ember.Object.create({ title: 'Task Title', settingsEnabled: true, settings: [] });
  this.set('task', taskTemplate);
  this.render(hbs`{{card-preview task=task}}`);
  assert.elementFound('.card--settings');
});

test('it does a settings icon if task does not have settings enabled', function(assert) {
  const taskTemplate = Ember.Object.create({ title: 'Task Title', settingsEnabled: false });
  this.set('task', taskTemplate);
  this.render(hbs`{{card-preview task=task}}`);
  assert.elementNotFound('.card--settings');
});
