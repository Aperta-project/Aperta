import Ember from 'ember';
import { moduleFor, test } from 'ember-qunit';

let healthCheckStub, pusherStub, pusherFailureMessagesStub, flashStub;

moduleFor('controller:application', 'Unit | Controller | application', {
  beforeEach: function() {
    healthCheckStub = { start: ()=>{} };
    pusherStub = Ember.Object.create({connection: { connection: { state: 'connecting' } }});
    pusherFailureMessagesStub = { failed: 'f', unavailable: 'u', disconnected: 'd' };
    flashStub = Ember.Object.create({
      systemLevelMessages: Ember.A(),
      displaySystemLevelMessage(type, message) {
        this.get('systemLevelMessages').pushObject({ text: message, type: type });
      },
    });
  }
});

test('Slanger notifications - happy path', function(assert) {
  assert.expect(3);
  let complete = assert.async();

  pusherStub.set('connection.connection.state', 'connecting');
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
    pusherStub.set('connection.connection.state', 'connected');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [], 'flash shows no connection messages');
    complete();
  });
});

test('Slanger notifications - failed to connect', function(assert) {

  assert.expect(4);
  let complete = assert.async();

  pusherStub.set('connection.connection.state', 'connecting');
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
    pusherStub.set('connection.connection.state', 'unavailable');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flashes unavailable message');
  });
  Ember.run(() => {
    pusherStub.set('connection.connection.state', 'failed');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}, {type: 'error', text: 'f'}],
      'flashes unavailable and failed messages');
    complete();
  });
});

test('Slanger notifications - spotty but ultimately able to connect', function(assert) {

  assert.expect(11);
  let complete = assert.async();

  pusherStub.set('connection.connection.state', 'connecting');  let controller = null;
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
    pusherStub.set('connection.connection.state', 'connected');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [], 'flash shows no connection messages');
  });
  Ember.run(() => {
    pusherStub.set('connection.connection.state', 'connecting');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [], 'flash shows no connection messages');
  });
  Ember.run(() => {
    pusherStub.set('connection.connection.state', 'unavailable');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message');
  });
  Ember.run(() => {
    pusherStub.set('connection.connection.state', 'connecting');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message');
  });
  Ember.run(() => {
    pusherStub.set('connection.connection.state', 'connected');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message after connecting');
  });
  Ember.run(() => {
    pusherStub.set('connection.connection.state', 'connecting');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message');
  });
  Ember.run(() => {
    pusherStub.set('connection.connection.state', 'unavailable');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message');
  });
  Ember.run(() => {
    pusherStub.set('connection.connection.state', 'connecting');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message');
  });
  Ember.run(() => {
    pusherStub.set('connection.connection.state', 'connected');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'u'}],
      'flash shows one message after reconnecting twice');
    complete();
  });
});

test('Slanger notifications - browser doesnt support web sockets', function(assert) {

  assert.expect(3);
  let complete = assert.async();

  pusherStub.set('connection.connection.state', 'connecting');
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
    pusherStub.set('connection.connection.state', 'failed');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'f'}],
      'flash disconnected message');
    complete();
  });
});

test('Slanger notifications - intentional disconnect', function(assert) {

  assert.expect(4);
  let complete = assert.async();
  
  pusherStub.set('connection.connection.state', 'connecting');  let controller = null;
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
    pusherStub.set('connection.connection.state', 'connected');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [], 'flash shows no connection messages');
  });

  Ember.run(() => {
    pusherStub.set('connection.connection.state', 'disconnected');
    assert.deepEqual(controller.get('flash').get('systemLevelMessages'), [{type: 'error', text: 'd'}],
      'flash disconnected message');
    complete();
  });
});
