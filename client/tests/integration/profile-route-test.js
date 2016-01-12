import { test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import Ember from 'ember';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';


module('Integration: Authorized Profile View', {
  beforeEach(){
    this.App = startApp();
    TestHelper.setup(this.App);
  },

  afterEach: function(){
    Ember.run(this.App, 'destroy');
  }
});

test('transition to route without permission fails', function(assert){
  Ember.run.later(function(){
    var store = getStore();
    store.createRecord('permission', { table: [] });

    visit('/profile');
    andThen(function(){
      assert.equal(currentPath(), 'dashboard.index');
    });
  });
});

test('transition to route with permission succeedes', function(assert){
  Ember.run.later(function(){
    var store = getStore();
    store.createRecord('permission',{
      table: [
        {
          object:{id: 1, type: 'User'},
          permissions:{
            view_profile:{
              states: ['*']
            }
          }
        }
      ]
    });

    visit('/profile');
    andThen(function(){
      assert.equal(currentPath(), 'profile');
    });
  })
});
