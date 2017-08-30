import { moduleFor, test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import startApp from '../helpers/start-app';
let App;

moduleFor('service:feature-flag', 'Unit | Service | Feature flag', {
  needs: ['model:feature-flag', 'service:store'],
  beforeEach() {
    App = startApp();
    TestHelper.setup(App);
  }
});

test('value returns the value of the flag', function(assert) {
  FactoryGuy.make('feature-flag');
  FactoryGuy.make('feature-flag', 'inactive');

  const value1 = this.subject().value('ACTIVE_FLAG');
  const value2 = this.subject().value('INACTIVE_FLAG');

  assert.ok(value1, 'the flag is active');
  assert.notOk(value2, 'the flag is inactive');
});
