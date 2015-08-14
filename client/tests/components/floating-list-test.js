import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs   from 'htmlbars-inline-precompile';

moduleForComponent('floating-list', 'FloatingList', {
  integration: true
});

test('floating-list positions below target', function(assert) {
  assert.expect(2);

  this.render(hbs`
    <div style="position: relative;">
      <div id="target-dom-node"
           style="position:absolute; top:40px; left:40px; width:100px; height:20px;"></div>

      {{#floating-list items=items
                       class="tha-list"
                       positionNearSelector="#target-dom-node"}}
        List goes here
      {{/floating-list}}
    </div>
  `);

  Ember.run(this, function() {
    let listPosition = this.$('.tha-list').position();
    let top  = listPosition.top;
    let left = listPosition.left;

    // target-dom-node top + height
    assert.equal(Math.round(top),  60, 'positioned directly below target');
    assert.equal(Math.round(left), 40, 'positioned left aligned with target');
  });
});

test('floating-list on top of target', function(assert) {
  assert.expect(2);

  this.render(hbs`
    <div style="position: relative;">
      <div id="target-dom-node"
           style="position:absolute; top:40px; left:40px; width:100px; height:20px;"></div>

      {{#floating-list items=items
                       class="tha-list"
                       positionOver=true
                       positionNearSelector="#target-dom-node"}}
        List goes here
      {{/floating-list}}
    </div>
  `);

  Ember.run(this, function() {
    let listPosition = this.$('.tha-list').position();
    let top  = listPosition.top;
    let left = listPosition.left;

    assert.equal(Math.round(top),  40, 'positioned directly over target');
    assert.equal(Math.round(left), 40, 'positioned left aligned with target');
  });
});
