/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
        'service:pusher',
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
  $.mockjax({ url: '/api/export_deliveries', type: 'POST', status: 201, responseText: {export_delivery: {id: '1'}} });
  let task = make('custom-card-task');
  this.set('task', task);
  this.set('content', { text: 'foo' });
  this.render(template);
  this.$('.send-to-apex-button').click();
  return wait().then(() => {
    let mockjaxCalls = $.mockjax.mockedAjaxCalls();
    let request = _.find(mockjaxCalls, {
      url: '/api/export_deliveries',
      type: 'POST'
    });

    let requestData = JSON.parse(request.data);
    assert.equal(
      requestData.export_delivery.destination,
      'foo',
      'it saves the card content text as the apex delivery destination'
    );
  });
});

test('it displays a list of deliveries', function(assert) {
  let task = make('custom-card-task');
  this.set('task', task);
  this.set('content', { text: 'foo' });
  make('export-delivery', {
    task: task,
    state: 'in_progress',
    destination: 'apex'
  });
  this.render(template);
  assert.elementFound('.export-delivery-message');
});
