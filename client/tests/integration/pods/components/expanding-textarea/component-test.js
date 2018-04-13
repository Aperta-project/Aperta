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

moduleForComponent('expanding-textarea', 'Integration | Component | expanding textarea', {
  integration: true
});

test('it renders a textarea when no block is provided', function(assert) {
  this.render(hbs`{{expanding-textarea}}`);

  assert.equal(this.$('textarea').length, 1, 'there is a textarea');
});

test('it lets the block render a textarea if one is provided', function(assert) {
  this.render(hbs`
    {{#expanding-textarea}}
      <textarea class="test"></textarea>
    {{/expanding-textarea}}
   `);

  assert.equal(this.$('textarea.test').length, 1, 'the block renders the textarea');
  assert.equal(this.$('textarea').length, 1, 'there is only one textarea');
});
