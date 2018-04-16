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

import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('binary-radio-button', 'Integration | Component | binary radio button', {
  integration: true,

  beforeEach() {
    this.set('hungry', null);
    this.actions = {
      yesAction() { this.set('hungry', true); },
      noAction()  { this.set('hungry', false); }
    };
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{binary-radio-button
      name="foobar"
      yesValue="foo"
      noValue="bar"
      selection="bar"}}
  `);

  assert.equal(this.$('input[type=radio]').length, 2);
});

test('it updates', function(assert) {
  this.render(hbs`
    {{binary-radio-button name="hungry"
                          yesValue=true
                          noValue=false
                          selection=hungry
                          yesAction="yesAction"
                          noAction="noAction"}}
  `);

  assert.equal(this.$('input:checked').length, 0, 'none checked when selection matches neither value');

  this.set('hungry', true);
  assert.equal(this.$('input:checked').length, 1, 'one checked');
  assert.ok(this.$('#hungry-yes').is(':checked'), 'yes is checked');

  this.set('hungry', false);
  assert.equal(this.$('input:checked').length, 1, 'one still checked');
  assert.ok(this.$('#hungry-no').is(':checked'), 'no is checked');
});
