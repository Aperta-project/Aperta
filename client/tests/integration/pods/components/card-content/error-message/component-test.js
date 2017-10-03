import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
moduleForComponent(
  'card-content/error-message',
  'Integration | Component | card content | error message',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
    }
  }
);

test('it renders the message from the scenario based on the content key', function(
  assert
) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.set(
    'scenario',
    Ember.Object.create({
      errors: { nestedError: 'This is an error' },
      topKey: 'Top message'
    })
  );

  this.set('content', Ember.Object.create({ key: 'errors.nestedError' }));
  this.render(
    hbs`{{card-content/error-message preview=false scenario=scenario content=content}}`
  );

  assert.textPresent(
    '.error-message',
    'This is an error',
    'allows for nested keys'
  );

  assert.elementFound('.error-message .fa-exclamation-triangle', 'shows an error icon');

  this.set('content.key', 'topKey');
  assert.textPresent('.error-message', 'Top message', 'allows for nested keys');

  this.set('content.key', 'no match');
  assert.elementFound('.error-message--hidden', 'The error message is hidden when the key does not match');
});
