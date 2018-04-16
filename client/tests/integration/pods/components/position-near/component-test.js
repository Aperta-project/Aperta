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

import Ember from 'ember';
import hbs   from 'htmlbars-inline-precompile';

moduleForComponent('position-near', 'Integration | Component | position near', {
  integration: true
});

/*
 * The div that Ember tests are render in is scaled down with CSS.
 * This breaks the expected results from $.position.
 */
let   testWindowScale;
const testWindowReset = function() {
  $('#ember-testing').css('transform', testWindowScale);
};
const testWindowFix   = function() {
  testWindowScale = $('#ember-testing').css('transform');
  $('#ember-testing').css('transform', 'scale(1)');
};

test('position-near positions below target', function(assert) {
  assert.expect(2);

  this.render(hbs`
    <div style="position:absolute; top:40px; left:40px; background:green;">
      <style>.list { background: red; }</style>
      <div id="target-dom-node" style="width:100px; height:100px; background:#999;"></div>

      {{#position-near items=items
                       class="list"
                       positionNearSelector="#target-dom-node"}}
        List goes here
      {{/position-near}}
    </div>
  `);

  Ember.run(this, function() {
    testWindowFix();

    const listPosition = this.$('.list').position();
    const top  = listPosition.top;
    const left = listPosition.left;

    // target-dom-node top + height
    assert.equal(Math.round(top),  100, 'positioned directly below target');
    assert.equal(Math.round(left), 0, 'positioned left aligned with target');

    testWindowReset();
  });
});
