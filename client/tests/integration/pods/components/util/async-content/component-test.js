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
import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('util/async-content', 'Integration | Component | async content', {
  integration: true,

  beforeEach() {
    this.template = hbs`
      {{#util/async-content concurrencyTask=task as |resolved|}}
        <span>resolved value is {{resolved}}</span>
      {{else}}
        loading
      {{/util/async-content}}
    `;
  }
});

test('yields the task\'s last completed value', function(assert) {
  assert.expect(1);

  this.set( 'task', Ember.Object.create({perform: () => {}, lastSuccessful: {value: 'done'}}));

  this.render(this.template);

  assert.ok(
    this.$().text().trim().match('done'),
    'task complete and yields returned value of promise'
  );
});

test('renders the else state if the task is not completed with a value', function(assert) {
  assert.expect(1);

  this.set( 'task', Ember.Object.create({perform: () => {} }));

  this.render(this.template);

  assert.equal(
    this.$().text().trim(),
    'loading',
    'loading state'
  );
});
