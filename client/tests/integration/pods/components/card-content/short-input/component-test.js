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

import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'card-content/short-input',
  'Integration | Component | card content | short input',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.set('actionStub', function() {});
      this.set('answer', Ember.Object.create());
      this.set('content', Ember.Object.create());
    }
  }
);

let template = hbs`{{card-content/short-input
answer=answer
content=content
disabled=disabled
valueChanged=(action actionStub)
}}`;

test(`it disables the input if disabled=true`, function(assert) {
  this.set('disabled', true);
  this.render(template);
  assert.elementFound('input[disabled]');
});

test(`it displays the value from answer.value`, function(assert) {
  this.set('answer', Ember.Object.create({ value: 'Bar' }));
  this.render(template);
  assert.equal(this.$('input').val(), 'Bar');
});

test(`it sends 'valueChanged' on change`, function(assert) {
  assert.expect(1);
  this.set('answer', Ember.Object.create({ value: 'Old' }));
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, 'New', 'it calls the action with the new value');
  });
  this.render(template);
  this.$('input').val('New').trigger('change').trigger('blur');
});

test(`it sends 'valueChanged' on input`, function(assert) {
  assert.expect(1);
  this.set('answer', Ember.Object.create({ value: 'Old' }));
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, 'New', 'it calls the action with the new value');
  });
  this.render(template);
  this.$('input').val('New').trigger('input').trigger('blur');
});

test('hides errors on init and displays error messages if appropriate', function(assert) {
  let errorsArr = ['Oh Noes', 'You fool!'];
  this.set(
    'answer',
    Ember.Object.create({ readyIssuesArray: errorsArr, shouldShowErrors: true })
  );
  this.render(template);
  assert.equal(this.$('.validation-error').length, 0, 'Two errors are present');

  // Trigger input and blur on the input to hit the displayErrors action
  this.$('input').val('New').trigger('input').trigger('blur');
  assert.equal(this.$('.validation-error').length, 2, 'Two errors are present');

  assert.equal(
    this.$('.validation-error').eq(0).text().trim(),
    errorsArr[0],
    'First error text matches'
  );
  assert.equal(
    this.$('.validation-error').eq(1).text().trim(),
    errorsArr[1],
    'Second error text matches'
  );
  assert.ok(
    this.$('.card-content-short-input').hasClass('has-error'),
    'error class present on parent element'
  );
});
