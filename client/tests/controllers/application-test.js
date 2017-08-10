import Ember from 'ember';
import { moduleFor, test } from 'ember-qunit';

let healthCheckStub, pusherStub, pusherFailureMessagesStub, flashStub;

moduleFor('controller:application', 'Unit | Controller | application', {
  beforeEach: function() {
    healthCheckStub = { start: ()=>{} };
    pusherStub = Ember.Object.create({connection: { connection: { state: 'connecting' } }});
    pusherFailureMessagesStub = { failed: 'f', unavailable: 'u' };
    flashStub = Ember.Object.create({
      systemLevelMessages: Ember.A(),
      displaySystemLevelMessage(type, message) {
        this.get('systemLevelMessages').pushObject({ text: message, type: type });
      },
    });
  }
});

test('Slanger notifications - happy path', function(assert) {

  assert.expect(2);
  let complete = assert.async();

  pusherStub.set('connection.connection.state', 'connected');
  pusherStub.set('isDisconnected', false);

  Ember.run(() => {
    let controller = this.subject({
      pusher: pusherStub,
      flash: flashStub,
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

  pusherStub.set('connection.connection.state', 'unavailable');
  pusherStub.set('isDisconnected', true);

  Ember.run(() => {
    let controller = this.subject({
      pusher: pusherStub,
      flash: flashStub,
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

  assert.expect(9);
  let complete = assert.async();

  pusherStub.connection.connection.state = 'connected';
  pusherStub.set('isDisconnected', false);

  let controller = null;
  Ember.run(() => {
    controller = this.subject({
      pusher: pusherStub,
      flash: flashStub,
      healthCheck: healthCheckStub,
      pusherFailureMessages: pusherFailureMessagesStub
    });

    assert.ok(controller);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [], 'flash shows no connection messages');
  });
  Ember.run(() => {
    pusherStub.connection.connection.state = 'disconnected';
    pusherStub.set('isDisconnected', true);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message');
  });
  Ember.run(() => {
    pusherStub.connection.connection.state = 'connecting';
    pusherStub.set('isDisconnected', true);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message');
  });
  Ember.run(() => {
    pusherStub.connection.connection.state = 'connected';
    pusherStub.set('isDisconnected', false);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message after connecting');
  });
  Ember.run(() => {
    pusherStub.connection.connection.state = 'connecting';
    pusherStub.set('isDisconnected', true);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message');
  });
  Ember.run(() => {
    pusherStub.connection.connection.state = 'unavailable';
    pusherStub.set('isDisconnected', true);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message');
  });
  Ember.run(() => {
    pusherStub.connection.connection.state = 'connecting';
    pusherStub.set('isDisconnected', true);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message');
  });
  Ember.run(() => {
    pusherStub.connection.connection.state = 'connected';
    pusherStub.set('isDisconnected', false);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message after connecting');
    complete();
  });
});

test('Slanger notifications - browser doesnt support web sockets', function(assert) {

  assert.expect(2);
  let complete = assert.async();

  pusherStub.set('connection.connection.state', 'failed');
  pusherStub.set('isDisconnected', true);

  Ember.run(() => {
    let controller = this.subject({ 
      pusher: pusherStub,
      flash: flashStub,
      healthCheck: healthCheckStub,
      pusherFailureMessages: pusherFailureMessagesStub
    });

    assert.ok(controller);
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'f'}], 
      'flash shows message for failed state');
    complete();
  });
});
