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

import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerDiffAssertions from 'tahi/tests/helpers/diff-assertions';

moduleForComponent('boolean-diff',
                   'Integration | Component | boolean diff',
                   {integration: true,
                    beforeEach: function() {
                      registerDiffAssertions();
                    }});

var template = hbs`{{boolean-diff
                      viewingBool=booleanToView
                      comparisonBool=booleanToCompare}}`;

test("displays no diff when same value", function(assert) {
  this.set('booleanToView', true);
  this.set('booleanToCompare', true);

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test("displays diff when value changed", function(assert) {
  this.set('booleanToView', true);
  this.set('booleanToCompare', false);

  this.render(template);
  assert.diffPresent('No', 'Yes');
});

test("displays boolean added when comparing boolean is null", function(assert) {
  this.set('booleanToView', true);
  this.set('booleanToCompare', null);

  this.render(template);
  assert.equal(this.$('.added').length, 1, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test("displays boolean removed when original viewing boolean is null", function(assert) {
  this.set('booleanToView', null);
  this.set('booleanToCompare', true);

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 1, 'Has removed diff spans');
});

test("displays boolean removed when original viewing boolean is undefined", function(assert) {
  this.set('booleanToView', undefined);
  this.set('booleanToCompare', true);

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 1, 'Has removed diff spans');
});

test("displays boolean added when comparing boolean is undefined", function(assert) {
  this.set('booleanToView', true);
  this.set('booleanToCompare', undefined);

  this.render(template);
  assert.equal(this.$('.added').length, 1, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});
