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

moduleForComponent('admin-page/settings',
                   'Integration | Component | Admin Page | Settings', {
                     integration: true
                   });

const journal = { name: 'My Journal' };

test('it renders the journal editing form', function(assert) {
  this.set('journal', journal);

  this.render(hbs`
    {{admin-page/settings journal=journal}}
  `);

  assert.elementFound('.journal-thumbnail-edit-form');
});

test('it renders the journal css editing buttons', function(assert) {
  this.set('journal', journal);

  this.render(hbs`
    {{admin-page/settings journal=journal}}
  `);

  assert.nElementsFound('.admin-journal-settings-buttons button', 2);
});

test('it prevents showing form when no journal is selected', function(assert) {
  this.set('journal', null);

  this.render(hbs`
    {{admin-page/settings journal=journal}}
  `);

  assert.elementNotFound('.journal-thumbnail-edit-form');
  assert.textPresent('.admin-journal-settings', 'select a specific journal');
});
