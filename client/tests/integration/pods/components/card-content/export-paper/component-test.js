import { moduleForComponent, test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import wait from 'ember-test-helpers/wait';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'card-content/export-paper',
  'Integration | Component | card content/export paper',
  {
    integration: true,
    beforeEach() {
      manualSetup(this.container);
      registerCustomAssertions();
      this.registry.register(
        'pusher:main',
        Ember.Object.extend({ socketId: 'foo' })
      );
    }
  }
);

let template = hbs`{{card-content/export-paper
  content=content
  owner=task
  disabled=disabled
}}`;

test('it shows a button with a label', function(assert) {
  this.render(template);
  assert.textPresent('.send-to-apex-button', 'Send to Apex');
});

test('looks properly disabled when disabled is true', function() {});

test('pushing the button saves a new apex delivery', function(assert) {
  $.mockjax({ url: '/api/apex_deliveries', type: 'POST', status: 204 });
  let task = FactoryGuy.make('custom-card-task');
  this.set('task', task);
  this.set('content', { text: 'foo' });
  this.render(template);
  this.$('.send-to-apex-button').click();
  return wait().then(() => {
    let mockjaxCalls = $.mockjax.mockedAjaxCalls();
    let request = _.find(mockjaxCalls, {
      url: '/api/apex_deliveries',
      type: 'POST'
    });

    let requestData = JSON.parse(request.data);
    assert.eq(
      requestData.apex_delivery.destination,
      'foo',
      'it saves the card content text as the apex delivery destination'
    );

    assert.textPresent('.apex-delivery-message', 'Apex Upload');
  });
  //make sure the attrs on the delivery are correct
});

test('it displays a list of deliveries', function() {
});
