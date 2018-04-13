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

moduleForComponent('card-editor/header', 'Integration | Component | card editor | header', {
  integration: true
});

test('it renders the card name', function(assert) {
  const card = Ember.Object.create({ name: 'baby-o', journal: {id: 5}});
  this.set('card', card);

  this.render(hbs`{{card-editor/header card=card}}`);

  assert.textPresent('.card-editor-header h1', card.get('name'));
});

test('it renders a back button', function(assert) {
  const card = Ember.Object.create({ name: 'baby-o', journal: {id: 5}});
  this.set('card', card);

  this.render(hbs`{{card-editor/header card=card}}`);

  assert.textPresent('.card-editor-header-back', 'Card Catalogue');
});

test('it renders navigation', function(assert) {
  const card = Ember.Object.create({ name: 'baby-o', journal: {id: 5}});
  this.set('card', card);

  this.render(hbs`{{card-editor/header card=card}}`);

  assert.elementFound('.tab-bar');
});
