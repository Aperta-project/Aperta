import Ember from 'ember';
import sinon from 'sinon';
import { moduleFor, test } from 'ember-qunit';

moduleFor('service:full-story', 'Unit | Service | full story', {
  beforeEach() {
    this.service = this.subject();
  }
});

const currentUser = Ember.Object.create({
  username: 'pikachu',
  email: 'pikachu@oak.edu',
  fullName: 'Pikachu Pokémon'
});

function withFS(test) {
  const identifySpy = sinon.spy();
  const clearUserCookieSpy = sinon.spy();
  const fs = window.FS;
  window.FS = {
    identify: identifySpy,
    clearUserCookie: clearUserCookieSpy
  };
  test.call(this, identifySpy, clearUserCookieSpy);
  window.FS = fs;
}

function withoutFS(test) {
  const fs = window.FS;
  delete window.FS;
  test.call();
  window.FS = fs;
}

test('identify() when FS is loaded', function(assert) {
  withFS((identifySpy) => {
    this.service.identify(currentUser);
    assert.spyCalledWith(
      identifySpy,
      [
        currentUser.get('username'),
        {
          email: currentUser.get('email'),
          displayName: currentUser.get('fullName')
        }
      ],
      'identify should be called with user details'
    );
  });
});

test('identify() when FS is not loaded', function(assert){
  withoutFS(() => {
    this.service.identify(currentUser);
    assert.ok('things should not blow up');
  });
});

test('clearSession() when FS is loaded', function(assert){
  withFS((_, clearUserCookieSpy) => {
    this.service.clearSession();
    assert.spyCalled(clearUserCookieSpy);
  });
});

test('clearSession() when FS is not loaded', function(assert){
  withoutFS(() => {
    this.service.clearSession();
    assert.ok('things should not blow up');
  });
});
