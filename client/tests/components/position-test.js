import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs   from 'htmlbars-inline-precompile';

moduleForComponent('position-near', 'Component: position-near', {
  integration: true
});

test('position-near positions below target', function(assert) {
  assert.expect(2);

  this.render(hbs`
    <div style="position:absolute; top:40px; left:40px;">
      <div id="target-dom-node" style=" width:100px; height:20px;"></div>

      {{#position-near items=items
                       class="tha-list"
                       positionNearSelector="#target-dom-node"}}
        List goes here
      {{/position-near}}
    </div>
  `);

  Ember.run(this, function() {
    let listPosition = this.$('.tha-list').position();
    let top  = listPosition.top;
    let left = listPosition.left;

    // target-dom-node top + height
    assert.equal(Math.round(top),  20, 'positioned directly below target');
    assert.equal(Math.round(left), 0, 'positioned left aligned with target');
  });
});
