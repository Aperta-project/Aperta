import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('auto-suggest-list', 'Component: auto-suggest-list', {
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
    <div id="auto-suggest-test">
      {{#auto-suggest-list items=items
                           positionNearSelector="#auto-suggest-test" as |user|}}
        {{user.name}}
      {{/auto-suggest-list}}
    </div>
  `);

  assert.equal(this.$('.auto-suggest').length, 1);
  assert.equal(
    this.$('.auto-suggest-item:first').text().trim(),
    name,
    'Block template is rendered'
  );
});
