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

moduleForComponent('show-if-editing', 'Integration | Component | show if editing', {
  integration: true,

  beforeEach() {
    this.set('empty', true);
  }
});

test('it renders', function(assert) {
  assert.expect(4);

  this.set('startFunction', function() { assert.ok(true, 'start action called'); });
  this.set('stopFunction',  function() { assert.ok(true, 'stop action called'); });

  this.render(hbs`
    {{#show-if-editing initialState=empty
                       startEditingCallback=startFunction
                       stopEditingCallback=stopFunction
                       as |editing start stop|}}
      {{#if editing}}
        <div class="text">EDITING</div>
        <span {{action stop}}>Stop</span>
      {{else}}
        <div class="text">NOT EDITING</div>
        <span {{action start}}>Start</span>
      {{/if}}
    {{/show-if-editing}}
  `);

  assert.equal(this.$('.text').text().trim(), 'EDITING', 'In editing state');
  this.$('span').click();
  assert.equal(this.$('.text').text().trim(), 'NOT EDITING', 'Not in editing state');
  this.$('span').click();
});
