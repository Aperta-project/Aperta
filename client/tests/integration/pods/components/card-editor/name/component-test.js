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

moduleForComponent('card-editor/name', 'Integration | Component | card editor | name', {
  integration: true
});

test('it renders the card name in a non-editing manner', function(assert) {
  const card = Ember.Object.create({ name: 'My Card', journal: {id: 9}});
  this.set('card', card);

  this.render(hbs`{{card-editor/name card=card}}`);

  assert.textPresent('.card-editor-name-container h1', card.get('name'));
  assert.elementNotFound('.card-editor-name-form');
});

test('it renders the card name in an editing manner when clicked', function(assert) {
  const card = Ember.Object.create({ name: 'My Card', journal: {id: 9}});
  this.set('card', card);

  this.render(hbs`{{card-editor/name card=card}}`);

  this.$('.card-editor-name-container h1').click();
  assert.elementFound('.card-editor-name-form');
});

test('it updates a record when the save button is clicked', function(assert) {
  const mockPromise = function() { return Ember.RSVP.resolve(); };
  const card = Ember.Object.create({ name: 'My Card', journal: {id: 9}, save: mockPromise });
  this.set('card', card);

  this.render(hbs`{{card-editor/name card=card editing=true}}`);

  this.$('.card-editor-name-field input').val('My New Card').change();
  this.$('button.card-editor-name-save').click();

  assert.textPresent('.card-editor-name-container h1', 'My New Card');
  assert.elementNotFound('.card-editor-name-form');
});

test('it does not update a record when the cancel button is clicked', function(assert) {
  const mockPromise = function() { return Ember.RSVP.resolve(); };
  const card = Ember.Object.create({ name: 'My Card', journal: {id: 9}, rollbackAttributes: mockPromise });
  this.set('card', card);

  this.render(hbs`{{card-editor/name card=card editing=true}}`);

  this.$('.card-editor-name-field input').val('My New Card').change();
  this.$('button.card-editor-name-cancel').click();

  assert.textPresent('.card-editor-name-container h1', 'My New Card');
  assert.elementNotFound('.card-editor-name-form');
});
