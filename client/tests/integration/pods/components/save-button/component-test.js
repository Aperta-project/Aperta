import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('save-button', 'Integration | Component | save button', {
  integration: true
});

test('it renders with text set', function(assert) {
  this.render(hbs`{{#save-button}}SAVE{{/save-button}}`);

  assert.equal(this.$().text().trim(), 'SAVE');
});

test('it is disabled by default', function(assert) {
  this.render(hbs`{{#save-button}}SAVE{{/save-button}}`);
  assert.ok(this.$('button[disabled]'));
});

test('it displays a spinner when loading', function(assert) {
  this.set('loading', true);
  this.render(hbs`{{#save-button displaySpinner=loading}}SAVE{{/save-button}}`);

  assert.ok(this.$('.progress-spinner--blue'), 'Displays progress spinner');
});