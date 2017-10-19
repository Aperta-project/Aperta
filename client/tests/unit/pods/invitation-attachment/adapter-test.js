import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';

moduleFor('adapter:invitation-attachment', 'Unit | Adapter | invitation attachment', { integration: true });

test('findRecord returns a hollow promise if it doesnt belongTo anything', function(assert) {
  assert.expect(1);
  let adapter = this.subject();
  let snapshot = Ember.Object.create({belongsTo() { return null; }});
  adapter.findRecord(null, null, null, snapshot).catch(() => {
    assert.ok(true);
  });
});
