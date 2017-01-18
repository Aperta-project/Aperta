import destroyApp from '../../helpers/destroy-app';
import Ember from 'ember';
import sinon from 'sinon';
import startApp from 'tahi/tests/helpers/start-app';
import { initialize } from 'tahi/instance-initializers/full-story-config';
import { module, test } from 'qunit';

const currentUser = Ember.Object.create({
  username: 'pikachu',
  email: 'pikachu@oak.edu',
  fullName: 'Pikachu Pokémon'
});

module('Unit | Instance Initializer | full story config', {
  beforeEach() {
    Ember.run(() => {
      this.application = startApp();
      this.appInstance = this.application.buildInstance();
      this.application.registry.register('user:current', currentUser, {
        instantiate: false
      });
      this.application.registry.injection('initializer:full-story-config', 'currentUser',  'user:current');
    });
  },
  afterEach() {
    Ember.run(this.appInstance, 'destroy');
    destroyApp(this.application);
  }
});

test('it does nothing when FS is not loaded', function(assert) {
  const fs = window.FS;
  delete window.FS;
  initialize(this.appInstance);
  assert.ok('things should not blow up');
  window.FS = fs;
});

test('it calls FS.identify when FS is loaded', function(assert) {
  const identifySpy = sinon.spy();
  window.FS = { identify: identifySpy };
  initialize(this.appInstance);
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
  delete window.FS;
});
