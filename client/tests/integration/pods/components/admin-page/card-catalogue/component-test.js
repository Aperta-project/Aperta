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

moduleForComponent('admin-page/card-catalogue', 'Integration | Component | admin page | card catalogue', {
  integration: true
});

test('it renders a catalogue', function(assert) {
  const cards = [];
  this.set('cards', cards);
  this.render(hbs`{{admin-page/card-catalogue cards=cards}}`);
  assert.elementFound('.admin-page-catalogue');
});

test('it renders an item for each unarchived card given', function(assert) {
  const journal = {name: 'My Journal'};
  const cards = [
    {title: 'Authors', journal: journal, isNew: false},
    {title: 'Tech Check', journal: journal, isNew: false},
    {title: 'Register Decision', journal: journal, isNew: false},
    {title: 'Archived Card', journal: journal, isNew: false, state: 'archived'}
  ];
  this.set('cards', cards);

  this.render(hbs`{{admin-page/card-catalogue cards=cards}}`);
  assert.nElementsFound('.admin-catalogue-item .admin-card-thumbnail', 3, `doesn't show archived cards`);
});
