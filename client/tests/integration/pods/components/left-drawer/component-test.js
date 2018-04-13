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

moduleForComponent('left-drawer', 'Integration | Component | left drawer', {
  integration: true
});


test('it renders its contents', function(assert) {
  this.render(hbs`
    {{#left-drawer}}
      A page goes here
    {{/left-drawer}}
  `);
  assert.equal(this.$().text().trim(), 'A page goes here');
});

test('it renders with an open drawer by default', function(assert) {
  this.render(hbs`
    {{#left-drawer}}
      A page goes here
    {{/left-drawer}}
  `);

  assert.elementFound(
    '.left-drawer-page.left-drawer-open',
    'should default to an open drawer'
  );
});


test('it renders a closed drawer if told to', function(assert) {
  this.render(hbs`
    {{#left-drawer open=false}}
      A page goes here
    {{/left-drawer}}
  `);

  assert.elementFound(
    '.left-drawer-page.left-drawer-closed',
    'should show a closed drawer'
  );
});


test('it closes and opens the drawer when toggle is called', function(assert) {
  this.render(hbs`
    {{#left-drawer as |toggle|}}
      {{left-drawer/drawer onToggle=toggle}}
    {{/left-drawer}}
  `);

  this.$('.left-drawer-toggle').click();

  assert.elementFound(
    '.left-drawer-page.left-drawer-closed',
    'should show a closed drawer after toggling'
  );

  this.$('.left-drawer-toggle').click();

  assert.elementFound(
    '.left-drawer-page.left-drawer-open',
    'should show a open drawer after toggling'
  );
});
