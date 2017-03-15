import Ember from 'ember';
import { moduleFor, test } from 'ember-qunit';
import sinon from 'sinon';

let pusherStub, flashStub, pusherFailureMessageSpy, displayFlashMessageSpy, healthCheckStub;

moduleFor('controller:application', 'Unit | Controller | application', {
  needs: ['model:journal'],
  beforeEach: function() {
    healthCheckStub = { start: ()=>{} };
    pusherStub = {connection: { connection: { state: 'connecting' } }};
    pusherFailureMessageSpy = sinon.stub().returns('oh noes -.-');
    displayFlashMessageSpy = sinon.spy();
    flashStub = Ember.Object.create({
      displaySystemLevelMessage: displayFlashMessageSpy,
      systemLevelMessages: Ember.A(),
      removeSystemLevelMessage: sinon.spy()
    });
  }
});

test('Slanger notifications - happy path', function(assert) {

  assert.expect(3);

  let complete = assert.async();

  pusherStub.connection.connection.state = 'connected';
  pusherStub.get = sinon.stub().withArgs('isDisconnected').returns(false);

  Ember.run(() => {
    let controller = this.subject({
      pusher: pusherStub,
      _pusherFailureMessage: pusherFailureMessageSpy,
      healthCheck: healthCheckStub,
      flash: flashStub
    });

    assert.ok(controller);

    assert.ok(pusherFailureMessageSpy.calledWith('connecting'),
      '_pusherFailureMessage was called with connecting');

    assert.ok(displayFlashMessageSpy.notCalled, 'displaySystemLevelMessage was NOT called');
    complete();

  });

});

test('Slanger notifications - unable to connect', function(assert) {

  assert.expect(3);

  let complete = assert.async();

  pusherStub.connection.connection.state = 'unavailable';
  pusherStub.get = sinon.stub().withArgs('isDisconnected').returns(true);

  Ember.run(() => {
    let controller = this.subject({
      pusher: pusherStub,
      _pusherFailureMessage: pusherFailureMessageSpy,
      healthCheck: healthCheckStub,
      flash: flashStub });

    assert.ok(controller);
    assert.ok(pusherFailureMessageSpy.calledWith('unavailable'), '_pusherFailureMessage was called');
    assert.ok(displayFlashMessageSpy.called, 'displaySystemLevelMessage was called');
    complete();

  });

});

test('Slanger notifications - browser doesnt support web sockets', function(assert) {

  assert.expect(3);

  let complete = assert.async();

  pusherStub.connection.connection.state = 'failed';
  pusherStub.get = sinon.stub().withArgs('isDisconnected').returns(true);

  Ember.run(() => {
    let controller = this.subject({ pusher: pusherStub,
      _pusherFailureMessage: pusherFailureMessageSpy,
      healthCheck: healthCheckStub,
      flash: flashStub });

    assert.ok(controller);
    assert.ok(pusherFailureMessageSpy.calledWith('failed'), '_pusherFailureMessage was called');
    assert.ok(displayFlashMessageSpy.called, 'displaySystemLevelMessage was called');
    complete();

  });

});

test('Slanger notifications - user was disconnected by the application', function(assert) {

  assert.expect(3);

  let complete = assert.async();

  pusherStub.connection.connection.state = 'disconnected';
  pusherStub.get = sinon.stub().withArgs('isDisconnected').returns(true);

  Ember.run(() => {
    let controller = this.subject({ pusher: pusherStub,
      _pusherFailureMessage: pusherFailureMessageSpy,
      healthCheck: healthCheckStub,
      flash: flashStub });

    assert.ok(controller);
    assert.ok(pusherFailureMessageSpy.calledWith('disconnected'), '_pusherFailureMessage was called');
    assert.ok(displayFlashMessageSpy.called, 'displaySystem LevelMessage was called');
    complete();

  });
});
