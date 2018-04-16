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

import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('radio-button', 'Integration | Component | radio button', {
  integration: true,

  beforeEach() {
    this.set('color', null);
    this.actions = {
      changeColor(color) {
        this.set('color', color);
      }
    };
  }
});

test('value is required', function(assert) {
  assert.expect(1);

  assert.throws(function() {
    this.subject(hbs`
      {{radio-button}}
    `);
  }, Error, 'has thrown an Error');
});

test('selection is required', function(assert) {
  assert.expect(1);

  assert.throws(function() {
    this.subject(hbs`
      {{radio-button value="red"}}
    `);
  }, Error, 'has thrown an Error');
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{radio-button value="red" selection=color}}
  `);

  assert.equal(this.$('input[type=radio]').length, 1);
});

test('it updates', function(assert) {
  assert.expect(8);

  this.render(hbs`
    {{radio-button id="red"   name="color" value="red"  selection=color
                   action=(action "changeColor")}}
    {{radio-button id="blue"  name="color" value="blue" selection=color
                   action=(action "changeColor")}}
    {{radio-button id="green" name="color" value="green"selection=color
                   action=(action "changeColor")}}
  `);

  assert.equal(this.$('input:checked').length, 0, 'none checked');

  // data down:
  this.set('color', 'red');
  assert.equal(this.$('input:checked').length, 1, 'one checked');
  assert.ok(this.$('#red').is(':checked'), 'red is checked');
  this.set('color', 'blue');
  assert.equal(this.$('input:checked').length, 1, 'one checked');
  assert.ok(this.$('#blue').is(':checked'), 'blue is checked');

  // actions up:
  this.$('#green').click();
  assert.equal(this.$('input:checked').length, 1, 'one checked');
  assert.ok(this.$('#green').is(':checked'), 'green is checked');
  assert.equal(this.get('color'), 'green', 'property updates');
});
