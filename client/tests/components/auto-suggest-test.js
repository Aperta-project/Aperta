import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs   from 'htmlbars-inline-precompile';


moduleForComponent('auto-suggest-list', 'AutoSuggestList', {
  integration: true,

  beforeEach() {
    this.set('userQuery', null);
    this.set('selectedUserName', null);

    this.set('items', [
      { name: 'Bob Joe' },
      { name: 'Joe Bob' }
    ]);

    this.actions = {
      selectItem(user) {
        this.set('selectedUserName', user.name);
      }
    };
  }
});

test('it renders', function(assert) {
  assert.expect(2);

  let name = this.get('items.firstObject').name;

  this.render(hbs`
    {{#auto-suggest-list items=items as |user|}}
      {{user.name}}
    {{/auto-suggest-list}}
  `);

  assert.equal(this.$('.auto-suggest').length, 1);
  assert.equal(this.$('.auto-suggest-item:first').text().trim(), name, 'Block template is rendered');
});

test('it positions near target', function(assert) {
  assert.expect(2);

  this.render(hbs`
    <div style="position:absolute; top:0; left:0;">
      <div id="target-dom-node"
           style="position:absolute; top:40px; left:40px; width:100px; height:20px;"></div>

      {{#auto-suggest-list items=items
                           positionNearSelector="#target-dom-node" as |user|}}
        {{user.name}}
      {{/auto-suggest-list}}
    </div>
  `);

  Ember.run(this, function() {
    let listPosition = this.$('.auto-suggest').position();
    let top  = listPosition.top;
    let left = listPosition.left;

    // target-dom-node top + height
    assert.equal(Math.round(top),  60, 'positioned directly below target');
    assert.equal(Math.round(left), 40, 'positioned left aligned with target');
  });
});
