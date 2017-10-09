import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';

moduleFor('service:store', 'Unit | Service | store', {
  integration: true
});

/*
 * peekTask is the public face of a few helper methods we use that depend on the internal
 * implementation of the store.
*/
test('peekTask finds any type of task in the store with the given id', function(assert) {
  let store = this.subject();
  Ember.run(() => {
    let t1 =    store.createRecord('ad-hoc-task', {id: '1'});
    let t2 =  store.createRecord('reviewer-report-task', {id: '2'});
    assert.equal(store.peekTask('1'), t1);
    assert.equal(store.peekTask('2'), t2);
  });
});
