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

moduleForComponent('save-button', 'Integration | Component | save button', {
  integration: true,
  beforeEach() {
    this.set('displaySpinner', false);
    this.set('disabled', false);
  }
});

test('it renders with text set', function(assert) {
  this.render(hbs`{{#save-button displaySpinner=displaySpinner disabled=disabled}}SAVE{{/save-button}}`);

  assert.equal(this.$().text().trim(), 'SAVE');
});

test('it is disabled by default', function(assert) {
  this.render(hbs`{{#save-button displaySpinner=displaySpinner disabled=disabled}}SAVE{{/save-button}}`);
  assert.ok(this.$('button[disabled]'));
});

test('it displays a spinner when loading', function(assert) {
  this.set('loading', true);
  this.render(hbs`{{#save-button displaySpinner=loading disabled=disabled}}SAVE{{/save-button}}`);

  assert.ok(this.$('.progress-spinner--blue'), 'Displays progress spinner');
});
