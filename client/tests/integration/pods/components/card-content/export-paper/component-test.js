import { moduleForComponent, test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('card-content/export-paper', 'Integration | Component | card content/export paper', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    registerCustomAssertions();
  }
});

let template = hbs`{{card-content/export-paper
  content=content
  owner=task
  disabled=disabled
}}`

test('it shows a button with a label', function(assert) {
  this.render(template);
  assert.textPresent('.send-to-apex-button', 'Send to Apex');
});

test('looks properly disabled when disabled is true', function() {
});

test('pushing the button saves a new apex delivery', function() {
    let task = FactoryGuy.make('custom-card-task');
    this.set('task', task);
    this.set('content', {text: 'foo'});
    this.render(template);
  
  //make sure the attrs on the delivery are correct
});

test('it displays a list of deliveries', function() {
});
