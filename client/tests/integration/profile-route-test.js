import { test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import Ember from 'ember';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import setupMockServer from '../helpers/mock-server';

server = null

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
  Ember.run.later(function(){
    var store = getStore();
    store.createRecord('permission', {id:'user+1'});

    visit('/profile');
    andThen(function(){
      assert.equal(
        currentPath(),
        'dashboard.index',
        "Should have redirected to the dashboard"
      );
    });
  });
});

test('transition to route with permission succeedes', function(assert){
  expect(1);
  Ember.run.later(function(){
    var store = getStore();
    store.createRecord('permission',{
      id: 'user+1',
      object:{id: 1, type: 'User'},
      permissions:{
        view_profile:{
          states: ['*']
        }
      }
    });

    visit('/profile');
    andThen(function(){
      assert.equal(
        currentPath(),
        'profile',
        'Should have visited the profile'
      );
    });
  })
});
