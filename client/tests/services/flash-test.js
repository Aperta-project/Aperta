import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';

let flash;

moduleFor('service:flash', 'Unit: Flash Service', {
  needs: [],
  beforeEach() {
    // the service object is a singleton, so we need to reset certain properties every time =(
    Ember.run(() => {
      flash = this.subject( {'systemLevelMessages': Ember.A(), 'routeLevelMessages': Ember.A() });
    });
  },
  afterEach() {
    Ember.run(() => {
      flash = this.subject( {'systemLevelMessages': Ember.A(), 'routeLevelMessages': Ember.A() });
    });
  }
});

test('displaySystemLevelMessage', function(assert) {
  assert.expect(2);

  flash.displaySystemLevelMessage('error', 'OMG MY APP IS ON FIRE!!!! =O');

  assert.equal(
    flash.get('systemLevelMessages').length,
    1,
    'systemLevelMessage has a message pushed into its queue');

  assert.equal(flash.get('routeLevelMessages').length,
    0,
    'routeLevelMessages doesnt have any messages pushed into its queue');

});

test('displayRouteLevelMessage', function(assert) {
  assert.expect(2);

  flash.displayRouteLevelMessage('error', 'OMG I did something wrong specific to this route!!!! =O');

  assert.equal(
    flash.get('systemLevelMessages').length,
    0,
    'systemLevelMessage doesnt have any messages pushed into its queue');

  assert.equal(
    flash.get('routeLevelMessages').length,
    1,
    'routeLevelMessages has a message pushed into its queue');

});

test('clearAllRouteLevelMessages', function(assert) {
  assert.expect(2);

  flash.displayRouteLevelMessage('error', 'OMG I did something wrong specific to this route!!!! =O');

  assert.equal(
    flash.get('routeLevelMessages').length,
    1,
    'routeLevelMessages has a message pushed into its queue');
  flash.clearAllRouteLevelMessages();

  assert.equal(
    flash.get('routeLevelMessages').length,
    0,
    'routeLevelMessages have been cleared of its messages');
});

test('clearAllSystemLevelMessages', function(assert) {
  assert.expect(2);

  flash.displaySystemLevelMessage('error', 'OMG MY APP IS ON FIRE!!!! =O');

  assert.equal(
    flash.get('systemLevelMessages').length,
    1,
    'systemLevelMessages has a message pushed into its queue');

  flash.clearAllSystemLevelMessages();

  assert.equal(
    flash.get('systemLevelMessages').length,
    0,
    'systemLevelMessages have been cleared of its messages');

});

test('removeSystemLevelMessage', function(assert){
  assert.expect(3);

  const distressingMessage = 'OMG MY APP IS ON FIRE!!!! =O';
  const someOtherMessage = 'NOOOOOOO!!!!!!!! >=(';

  flash.displaySystemLevelMessage('error', distressingMessage);
  flash.displaySystemLevelMessage('error', someOtherMessage);

  assert.equal(
    flash.get('systemLevelMessages').length,
    2,
    'SystemLevelMessages has two messages pushed into its queue');

  let messageToRemove = flash.get('systemLevelMessages').findBy('text', distressingMessage);

  flash.removeSystemLevelMessage(messageToRemove);

  assert.equal(
    flash.get('systemLevelMessages').length,
    1,
    'SystemLevelMessages has only one message now');

  let remainingMessage = flash.get('systemLevelMessages').findBy('text', someOtherMessage);

  assert.equal(
    remainingMessage.text,
    someOtherMessage,
    'the other message is still in the queue');

});

test('removeRouteLevelMessage', function(assert){
  assert.expect(3);

  const distressingMessage = 'OMG MY APP IS ON FIRE!!!! =O';
  const someOtherMessage = 'NOOOOOOO!!!!!!!! >=(';

  flash.displayRouteLevelMessage('error', distressingMessage);
  flash.displayRouteLevelMessage('error', someOtherMessage);

  assert.equal(
    flash.get('routeLevelMessages').length,
    2,
    'routeLevelMessages has two messages pushed into its queue');

  let messageToRemove = flash.get('routeLevelMessages').findBy('text', distressingMessage);

  flash.removeRouteLevelMessage(messageToRemove);

  assert.equal(
    flash.get('routeLevelMessages').length,
    1,
    'routeLevelMessages has only one message now');

  let remainingMessage = flash.get('routeLevelMessages').findBy('text', someOtherMessage);

  assert.equal(
    remainingMessage.text,
    someOtherMessage,
    'the other message is still in the queue');

});
