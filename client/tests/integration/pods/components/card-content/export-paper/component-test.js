import { moduleForComponent, test } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import Ember from 'ember';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import wait from 'ember-test-helpers/wait';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'card-content/export-paper',
  'Integration | Component | card content | export paper',
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

test('it shows a button with a label whose text is the label attribute of card content', function(
  assert
) {
  this.set('content', { label: 'Send to EM' });
  this.render(template);
  assert.textPresent('.send-to-apex-button', 'Send to EM');
});

test('looks properly disabled when disabled is true', function(assert) {
  this.set('content', { label: 'Send to EM' });
  this.set('disabled', true);
  this.render(template);
  assert.elementFound('.send-to-apex-button.disabled');
});

test('pushing the button saves a new apex delivery using the text of the card content', function(
  assert
) {
  $.mockjax({ url: '/api/apex_deliveries', type: 'POST', status: 204 });
  let task = make('custom-card-task');
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
    assert.equal(
      requestData.apex_delivery.destination,
      'foo',
      'it saves the card content text as the apex delivery destination'
    );
  });
});

test('it displays a list of deliveries', function(assert) {
  let task = make('custom-card-task');
  this.set('task', task);
  this.set('content', { text: 'foo' });
  make('apex-delivery', {
    task: task,
    state: 'in_progress',
    destination: 'apex'
  });
  this.render(template);
  assert.elementFound('.export-delivery-message');
});
