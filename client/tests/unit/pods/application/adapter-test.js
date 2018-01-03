import Ember from 'ember';
import { moduleFor, test } from 'ember-qunit';

moduleFor('adapter:application', 'Unit | Adapter | application', {
  needs: ['service:pusher']
});

test('headers conditionally contain Pusher-Socket-ID', function(assert) {
  let fakePusher = Ember.Object.create({socketId: null});
  this.subject().set('pusher', fakePusher);
  assert.deepEqual(this.subject().get('headers'), {namespace: 'api'}, 'Does not container socket id');
  fakePusher.set('socketId', '1111');
  assert.deepEqual(this.subject().get('headers'),
    { 'Pusher-Socket-ID': '1111',
      'namespace': 'api' }, 'contains pusher socket id');
});
