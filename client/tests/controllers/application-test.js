import Ember from 'ember';
import { moduleFor, test } from 'ember-qunit';
import sinon from 'sinon';

let pusherStub, flashStub, pusherFailureMessageSpy, displayFlashMessageSpy;

moduleFor('controller:application', 'Unit | Controller | application', {
  needs: ['model:journal'],
  beforeEach: function() {
    pusherStub = {connection: { connection: { state: 'connecting' } }};
    pusherFailureMessageSpy = sinon.mock().returns('oh noes -.-');
    displayFlashMessageSpy = sinon.spy();
    flashStub = Ember.Object.create({ displayMessage: displayFlashMessageSpy });
  }
});

test('Slanger notifications - happy path', function(assert) {

  assert.expect(3);

  let complete = assert.async();

  pusherStub.connection.connection.state = 'connected';
  pusherStub.get = sinon.stub().withArgs('isDisconnected').returns(false);

  Ember.run(() => {
    let controller = this.subject({ pusher: pusherStub,
      _pusherFailureMessage: pusherFailureMessageSpy,
      flash: flashStub });

    Ember.run.schedule('afterRender', () => {
      assert.ok(controller);
      assert.ok(pusherFailureMessageSpy.notCalled, '_pusherFailureMessage was NOT called');
      assert.ok(displayFlashMessageSpy.notCalled, 'displayMessage was NOT called');
      complete();
    });
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
      flash: flashStub });

    Ember.run.schedule('afterRender', () => {
      assert.ok(controller);
      assert.ok(pusherFailureMessageSpy.calledWith('unavailable'), '_pusherFailureMessage was called');
      assert.ok(displayFlashMessageSpy.called, 'displayMessage was called');
      complete();
    });

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
      flash: flashStub });

    Ember.run.schedule('afterRender', () => {
      assert.ok(controller);
      assert.ok(pusherFailureMessageSpy.calledWith('failed'), '_pusherFailureMessage was called');
      assert.ok(displayFlashMessageSpy.called, 'displayMessage was called');
      complete();
    });
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
      flash: flashStub });
    Ember.run.schedule('afterRender', () => {
      assert.ok(controller);
      assert.ok(pusherFailureMessageSpy.calledWith('disconnected'), '_pusherFailureMessage was called');
      assert.ok(displayFlashMessageSpy.called, 'displayMessage was called');
      complete();
    });
  });
});
