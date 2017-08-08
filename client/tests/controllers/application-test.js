import Ember from 'ember';
import { moduleFor, test } from 'ember-qunit';

let healthCheckStub, pusherStub, pusherFailureMessagesStub;

moduleFor('controller:application', 'Unit | Controller | application', {
  needs: ['service:flash'],
  beforeEach: function() {
    healthCheckStub = { start: ()=>{} };
    pusherStub = Ember.Object.create({connection: { connection: { state: 'connecting' } }});
    pusherFailureMessagesStub = {
      failed: 'f',
      unavailable: 'u',
      connecting: 'c',
      disconnected: 'd'
    };
  }
});

test('Slanger notifications - happy path', function(assert) {

  assert.expect(2);
  let complete = assert.async();

  pusherStub.connection.connection.state = 'connected';
  pusherStub.isDisconnected = false;

  Ember.run(() => {
    let controller = this.subject({
      pusher: pusherStub,
      healthCheck: healthCheckStub
    });

    assert.ok(controller);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [], 'flash messages are empty');
    complete();
  });
});

test('Slanger notifications - unable to connect', function(assert) {

  assert.expect(2);
  let complete = assert.async();

  pusherStub.connection.connection.state = 'unavailable';
  pusherStub.isDisconnected = true;

  Ember.run(() => {
    let controller = this.subject({
      pusher: pusherStub,
      healthCheck: healthCheckStub,
      pusherFailureMessages: pusherFailureMessagesStub
    });

    assert.ok(controller);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}], 
      'flash shows message for unavailable state');
    complete();
  });
});

test('Slanger notifications - repeatedly unable to connect', function(assert) {

  assert.expect(2);
  let complete = assert.async();

  pusherStub.connection.connection.state = 'unavailable';
  pusherStub.isDisconnected = true;

  Ember.run(() => {
    let controller = this.subject({
      pusher: pusherStub,
      healthCheck: healthCheckStub,
      pusherFailureMessages: pusherFailureMessagesStub
    });

    pusherStub.connection.connection.state = 'connected';
    pusherStub.set('isDisconnected', false);
    pusherStub.connection.connection.state = 'unavailable';
    pusherStub.set('isDisconnected', true);
    pusherStub.connection.connection.state = 'connected';
    pusherStub.set('isDisconnected', false);
    pusherStub.connection.connection.state = 'unavailable';
    pusherStub.set('isDisconnected', true);

    assert.ok(controller);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}], 
      'flash shows only one message');
    complete();
  });
});

test('Slanger notifications - browser doesnt support web sockets', function(assert) {

  assert.expect(2);
  let complete = assert.async();

  pusherStub.connection.connection.state = 'failed';
  pusherStub.isDisconnected = true;

  Ember.run(() => {
    let controller = this.subject({ 
      pusher: pusherStub,
      healthCheck: healthCheckStub,
      pusherFailureMessages: pusherFailureMessagesStub
    });

    assert.ok(controller);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'f'}], 
      'flash shows message for failed state');
    complete();
  });
});

test('Slanger notifications - user was disconnected by the application', function(assert) {

  assert.expect(2);
  let complete = assert.async();

  pusherStub.connection.connection.state = 'disconnected';
  pusherStub.isDisconnected = true;

  Ember.run(() => {
    let controller = this.subject({ 
      pusher: pusherStub,
      healthCheck: healthCheckStub,
      pusherFailureMessages: pusherFailureMessagesStub
    });

    assert.ok(controller);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'd'}], 
      'flash shows message for disconnected state');
    complete();
  });
});
