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
