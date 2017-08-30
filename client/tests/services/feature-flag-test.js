import { moduleFor, test } from 'ember-qunit';
import { make, manualSetup }  from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import startApp from '../helpers/start-app';

moduleFor('service:feature-flag', 'Unit | Service | Feature flag', {
  needs: ['model:feature-flag', 'service:store'],
  beforeEach() {
    manualSetup(this.container);
  }
});

test('value returns the value of the flag', function(assert) {
  make('feature-flag', {id: 1, name: 'ACTIVE_FLAG', active: true});
  make('feature-flag', {id: 2, name: 'INACTIVE_FLAG', active: false});

  const value1 = this.subject().value('ACTIVE_FLAG');
  const value2 = this.subject().value('INACTIVE_FLAG');

  assert.ok(value1, 'the flag is active');
  assert.notOk(value2, 'the flag is inactive');
});
