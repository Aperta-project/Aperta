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
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';


moduleForComponent('admin-page/card-thumbnail', 'Integration | Component | admin page | card thumbnail', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
  }
});

const journal = {name: 'The best journal'};
const card = {name: 'My special card', journal: journal};

test('it shows the name of the card', function(assert) {
  this.set('card', card);
  this.render(hbs`{{admin-page/card-thumbnail card=card}}`);

  assert.textPresent('.admin-card-thumbnail-name', card.name);
});

test("it shows the name of the card's journal", function(assert) {
  this.set('card', card);
  this.render(hbs`{{admin-page/card-thumbnail card=card}}`);

  assert.textPresent('.admin-card-thumbnail-journal', journal.name);
});
