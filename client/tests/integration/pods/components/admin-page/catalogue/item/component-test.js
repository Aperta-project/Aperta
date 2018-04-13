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
import sinon from 'sinon';

moduleForComponent('admin-page/catalogue/item', 'Integration | Component | Admin Page | Catalogue | Item', {
  integration: true
});

test('it renders its contents in a classy div', function(assert) {
  this.render(hbs`
    {{#admin-page/catalogue/item}}
      admin-page catalogue item content goes here.
    {{/admin-page/catalogue/item}}
  `);

  assert.equal(this.$().text().trim(), 'admin-page catalogue item content goes here.');
  assert.elementFound('.admin-catalogue-item');
});

test('it handles click action', function(assert) {

  const clicker = sinon.stub();
  this.on('click', clicker);

  this.render(hbs`
    {{#admin-page/catalogue/item action=(action "click")}}
      admin-page catalogue item content goes here
    {{/admin-page/catalogue/item}}
  `);

  this.$('.admin-catalogue-item').click();

  assert.spyCalled(clicker,
    'Calls click event on passed in action');
});
