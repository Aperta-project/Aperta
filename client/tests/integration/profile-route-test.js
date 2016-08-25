import { test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import Ember from 'ember';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';

var server = null;

module('Integration: Authorized Profile View', {
  beforeEach(){
    this.App = startApp();
    TestHelper.setup(this.App);
    server = setupMockServer();
    server.respondWith(
      'GET',
      '/api/papers',
      [
        200,
        { 'content-type': 'application/html'},
        JSON.stringify({'papers':[]})
      ]
    );
    server.respondWith(
      'GET',
      '/api/invitations',
      [
        200,
        { 'content-type': 'application/json'},
        JSON.stringify({invitations:[]})
      ]
    );
    server.respondWith(
      'GET',
      '/api/affiliations',
      [
        200,
        { 'content-type': 'application/json'},
        JSON.stringify({affiliations:[]})
      ]
    );
    server.respondWith(
      'GET',
      '/api/countries',
      [
        200,
        { 'content-type': 'application/json'},
        JSON.stringify({"countries":["doesntmatter"]})
      ]
    );
    server.respondWith(
      'GET',
      '/api/affiliations/user/1',
      [
        200,
        { 'content-type': 'application/json'},
        JSON.stringify({})
      ]
    );
    server.respondWith('GET',
                       '/api/journals',
                       [
                         200,
                         { 'Content-Type': 'application/json' },
                         JSON.stringify({journals:[]})
                       ]
    );

  },

  afterEach: function(){
    Ember.run(this.App, 'destroy');
    server.restore();
  }
});

test('transition to route without permission fails', function(assert){
  expect(1);
  // This tells the qunit test runner that it needs to stop and wait for
  // something asynchronous. calling start() indicates to qunit that the async
  // code has finished and that it can move on.  Without this, the callback
  // below is actually executed during the next test which causes it to fail.
  // https://api.qunitjs.com/async/
  const start = assert.async();

  Ember.run.later(function(){
    Factory.createPermission('User', 1, []);

    visit('/profile');
    andThen(function(){
      assert.equal(
        currentPath(),
        'dashboard.index',
        "Should have redirected to the dashboard"
      );
      start();
    });
  });
});

test('transition to route with permission succeedes', function(assert){
  expect(1);
  // stop qunit for async code. See note above
  const start = assert.async();

  Ember.run.later(function(){
    Factory.createPermission('User', 1, ['view_profile']);

    visit('/profile');
    andThen(function(){
      assert.equal(
        currentPath(),
        'profile',
        'Should have visited the profile'
      );
      start();
    });
  });
});

test('User is linked to thier Akita profile page', function(assert) {
  expect(3);
  Factory.createPermission('User', 1, ['view_profile']);

  visit('/profile');
  andThen(function() {
    let profileLink = Ember.$('.profile-link a');

    assert.ok(profileLink.length, 'There is a profile link');

    let expectedLinkText = 'View or edit your full profile';
    assert.textPresent('.profile-link a', expectedLinkText,
                       'The profile link is correctly labeled');

    let actualLinkSrc = profileLink.attr('href');
    let expectedLinkSrc = 'https://community.plos.org/account/edit-profile';
    assert.equal(actualLinkSrc, expectedLinkSrc,
                 'The profile link links to akita.');
  });
});
