import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('admin-page/drawer-item', 'Integration | Component | Admin Page | Drawer Item', {
  integration: true
});

test('it renders its contents', function(assert) {
  this.render(hbs`
    {{admin-page/drawer-item initials="acc" title="mister manager"}}
  `);
  assert.textPresent('.admin-drawer-item-initials', 'acc');
  assert.textPresent('.admin-drawer-item-title', 'mister manager');
});
