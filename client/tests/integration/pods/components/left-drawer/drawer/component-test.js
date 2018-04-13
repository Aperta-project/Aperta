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
import sinon from 'sinon';

moduleForComponent('left-drawer/drawer', 'Integration | Component | left drawer | drawer', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
  }
});

test('it renders its contents in a classy div', function(assert) {
  this.render(hbs`
    {{#left-drawer/drawer}}
      Drawer bits go here
    {{/left-drawer/drawer}}
  `);

  assert.equal(this.$().text().trim(), 'Drawer bits go here');
  assert.elementFound('.left-drawer.left-drawer-width');
});

test('it renders the title if there is one', function(assert) {
  this.render(hbs`
    {{#left-drawer/drawer title="Drawer title"}}
      Drawer bits go here
    {{/left-drawer/drawer}}
  `);

  assert.equal(this.$('.left-drawer-title').text().trim(),
    'Drawer title',
    'should render the title in title div');
});

test('it calls onToggle when the toggle is clicked', function(assert) {
  const toggler = sinon.stub();
  this.on('toggle', toggler);

  this.render(hbs`
    {{#left-drawer/drawer onToggle=(action "toggle")}}
      Drawer bits go here
    {{/left-drawer/drawer}}
  `);

  this.$('.left-drawer-toggle').click();

  assert.spyCalled(toggler,
    'Calls onToggle when the toggler is toggled');
});
