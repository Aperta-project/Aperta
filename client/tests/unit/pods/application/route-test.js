import { moduleFor, test } from 'ember-qunit';
import sinon from 'sinon';
import Ember from 'ember';

moduleFor('route:application', 'Unit | Route | application', {
  needs: ['service:full-story']
});

test('signOut ends the user\'s full story session', function(assert) {
  const clearSessionSpy = sinon.spy();
  const fullStoryMock = Ember.Service.extend({
    clearSession: clearSessionSpy
  });
  this.container.registry.register('service:full-story', fullStoryMock);
  const route = this.subject();
  const stub = sinon.stub(route, 'assignWindowLocation');
  route.send('signOut');
  assert.spyCalled(clearSessionSpy);
  stub.restore();
});

test('signOut changes the window.location', function(assert) {
  const route = this.subject();
  const mock = sinon.mock(route);
  const expectation = mock.expects('assignWindowLocation');
  route.send('signOut');
  assert.spyCalledWith(expectation, ['/users/sign_out'], 'assignWindowLocation() should have been called');
  mock.restore();
});
