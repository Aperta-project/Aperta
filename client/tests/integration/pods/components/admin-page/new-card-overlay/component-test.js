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
import { mockCreate } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';
import sinon from 'sinon';

moduleForComponent(
  'admin-page/new-card-overlay',
  'Integration | Component | Admin page | new card overlay',
  {
    integration: true,

    beforeEach() {
      manualSetup(this.container);
      registerCustomAssertions();
      this.registry.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
      this.set(
        'journal',
        make('admin-journal', { cardTaskTypes: [make('card-task-type')] })
      );
    },

    afterEach() {
      $.mockjax.clear();
    }
  }
);

let template = hbs`{{admin-page/new-card-overlay
    journal=journal
    success=(action "success")
    close=(action "close")}}`;

test('it creates a record when the save button is pushed', function(assert) {
  const success = sinon.spy();
  this.on('success', success);
  const close = sinon.spy();
  this.on('close', close);

  mockCreate('card');

  this.render(template);

  this.$('.admin-overlay-save').click();
  return wait().then(() => {
    assert.mockjaxRequestMade('/api/cards', 'POST');
    assert.spyCalled(success, 'Should call success callback');
    assert.spyCalled(close, 'Should call close');
  });
});

test('it does not create a record when the cancel button is pushed', function(
  assert
) {
  const success = sinon.spy();
  this.on('success', success);
  const close = sinon.spy();
  this.on('close', close);

  mockCreate('card');

  this.render(template);

  this.$('.admin-overlay-cancel').click();

  return wait().then(() => {
    assert.mockjaxRequestNotMade('/api/cards', 'POST');
    assert.spyNotCalled(success, 'Should not call success callback');
    assert.spyCalled(close, 'Should call close');
  });
});
