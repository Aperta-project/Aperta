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

let template = hbs`{{card-content/error-message
preview=false
scenario=scenario
content=content}}`;

test('it renders the message from the scenario based on the content key', function(assert) {
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
  this.render(template);

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
