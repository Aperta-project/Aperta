import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('card-content/validation-errors', 'Integration | Component | card content/validation errors', {
  integration: true
});

test('it renders', function(assert) {

  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.render(hbs`{{card-content/validation-errors}}`);

  assert.equal(this.$().text().trim(), '');
});

test('it shows errors', function(assert) {

  const firstExpectedError = 'ZOMG this is totally wrong';
  const secondExpectedError = `that's wrong too!`;
  this.set('errors', Ember.A([firstExpectedError, secondExpectedError]));

  this.render(hbs`{{card-content/validation-errors errors=errors}}`);

  assert.equal(this.$('.validation-error').eq(0).text().trim(), firstExpectedError);
  assert.equal(this.$('.validation-error').eq(1).text().trim(), secondExpectedError);
});
