import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';

moduleForComponent('admin-page/drawer-item', 'Integration | Component | Admin Page | Drawer Item', {
  integration: true,
  beforeEach: function() {
    manualSetup(this.container);
    this.register('service:can', FakeCanService);
  }
});

test('it renders its contents', function(assert) {
  const journal = FactoryGuy.make('journal');

  this.set('journal', journal);
  let can = this.container.lookup('service:can');

  can.allowPermission('administer', journal);

  this.render(hbs`
    {{admin-page/drawer-item journal=journal initials="acc" title="mister manager"}}
  `);
  assert.textPresent('.admin-drawer-item-initials', 'acc');
  assert.textPresent('.admin-drawer-item-title', 'mister manager');
});
