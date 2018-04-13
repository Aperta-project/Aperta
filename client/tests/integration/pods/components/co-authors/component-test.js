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

moduleForComponent('co-authors', 'Integration | Component | co authors', {
  integration: true
});

test('it renders a coauthorship confirmation form when the author is confirmable', function(assert) {
  this.set('model', {confirmationState: 'unconfirmed', paperTitle: 'Some title', createdAt: new Date('10/3/2013')});
  this.render(hbs`{{co-authors author=model}}`);

  assert.textPresent(this.$('.dashboard-paper-title'), 'Some title');
  assert.textPresent(this.$('.confirmation-metadata .date'), 'Oct 3, 2013');
  assert.textNotPresent(this.$('.message.thank-you'), 'Thank You!');
});

test('it renders "Thank You" when the author is confirmed', function(assert) {
  this.set('model', {confirmationState: 'confirmed', paperTitle: 'Some title', createdAt: new Date('10/3/2013')});
  this.render(hbs`{{co-authors author=model}}`);

  assert.textNotPresent(this.$('.dashboard-paper-title'), 'Some title');
  assert.textNotPresent(this.$('.confirmation-metadata .date'), 'Oct 3, 2013');
  assert.textPresent(this.$('.message.thank-you'), 'Thank You!');
});

test('it renders blank when the authorship is refuted', function(assert) {
  this.set('model', {confirmationState: 'refuted', paperTitle: 'Some title', createdAt: new Date('10/3/2013')});
  this.render(hbs`{{co-authors author=model}}`);

  assert.textNotPresent(this.$('.dashboard-paper-title'), 'Some title');
  assert.textNotPresent(this.$('.confirmation-metadata .date'), 'Oct 3, 2013');
  assert.textNotPresent(this.$('.message.thank-you'), 'Thank You!');
});
