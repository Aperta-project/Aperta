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

moduleForComponent(
  'card-editor/preview',
  'Integration | Component | card editor | preview',
  {
    integration: true
  }
);

const card = Ember.Object.create({
  name: 'Fig',
  content: Ember.Object.create({
    contentType: 'display-children',
    children: [],
    answerForOwner() {
      return null;
    }
  })
});

test('it renders a preview (defaults wide)', function(assert) {
  this.set('card', card);
  this.render(hbs`{{card-editor/preview card=card}}`);

  assert.elementFound('.card-editor-preview-overlay');
  assert.elementNotFound('.card-editor-preview-sidebar');
});

test('it renders a preview (narrow when sidebar-preview)', function(assert) {
  this.set('card', card);
  this.render(hbs`{{card-editor/preview card=card sidebar=true}}`);

  assert.elementFound('.card-editor-preview-sidebar');
  assert.elementNotFound('.card-editor-preview-overlay');
});

test('it has buttons for toggling width', function(assert) {
  this.set('card', card);
  this.render(hbs`{{card-editor/preview card=card}}`);

  assert.elementFound('.card-editor-preview-overlay');
  $('.card-editor-sidebar-button').click();
  assert.elementFound('.card-editor-preview-sidebar');
  $('.card-editor-full-screen-button').click();
  assert.elementFound('.card-editor-preview-overlay');
});
