import { moduleForModel, test } from 'ember-qunit';
import { make, manualSetup }  from 'ember-data-factory-guy';

moduleForModel('due-datetime', 'Unit | Model | due datetime', {
  beforeEach() {
    manualSetup(this.container);
  }
});

test('the factory', function(assert) {
  let model = make('due-datetime');
  assert.ok(!!model);
  assert.ok(moment(model.get('dueAt')).isValid(), 'dueAt is a valid date string');
});
