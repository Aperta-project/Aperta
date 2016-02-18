import { moduleFor, test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import Ember from 'ember';

moduleFor('service:can', 'Unit: Can Service Permissions', {
  needs: ['model:permission', 'model:paper'],
  beforeEach(){
    this.App = startApp();
    this.store = this.App.__container__.lookup('store:main');
    this.container = this.App.__container__;
    let store = this.store;

    this.permission = Ember.run(function(){
      return store.createRecord('permission', {id:'Paper+1'});
    });
    this.resource = Ember.run(function(){
      return store.createRecord('Paper', {id:1});
    });
  },

  afterEach: function() {
    Ember.run(this.App, 'destroy');
  }
});

test('permission is denied when permissions are empty', function(assert){
  expect(1);
  let can = this.subject();
  let resource = this.resource;
  can.set('container', this.container);
  return Ember.run(function(){
    resource.setProperties({id: 1});
    return can.can('some_action', resource).then(function(value){
      assert.equal(value, false, 'Should not be granted permission');
    });
  });
});

test('permission is granted when `action` is allowed', function(assert){
  expect(1);
  let can = this.subject();
  let resource = this.resource;
  let permission = this.permission;
  can.set('container', this.container);
  return Ember.run(function(){
    resource.setProperties({id: 1});
    permission.setProperties({
      permissions: {
        view: { states: ['*'] }
      }
    });

    return can.can('view', resource).then(function(value){
      assert.equal(value, true, 'Should be granted permission');
    });
  });
});

test('permission is denied when `action` is not allowed', function(assert){
  expect(1);
  let can = this.subject();
  let resource = this.resource;
  let permission = this.permission;
  can.set('container', this.container);
  return Ember.run(function(){
    resource.setProperties({id: 1});
    permission.setProperties({
      permissions: {
        view: { states: ['*'] }
      }
    });
    return can.can('edit', resource).then(function(value){
      assert.equal(value, false, 'Should not be granted permission');
    });
  });
});

test('permission is granted when `action` is allowed for state', function(assert){
  expect(1);
  let can = this.subject();
  let resource = this.resource;
  let permission = this.permission;
  can.set('container', this.container);
  return Ember.run(function(){
    resource.setProperties({id: 1, permissionState:'open'});
    permission.setProperties({
      permissions: {
        view: { states: ['open'] }
      }
    });
    return can.can('view', resource).then(function(value){

      assert.equal(value, true, 'Should be granted permission');
    });
  });
});

test('permission is denied when `action` is not allowed for state', function(assert){
  expect(1);
  let can = this.subject();
  let resource = this.resource;
  let permission = this.permission;
  can.set('container', this.container);
  return Ember.run(function(){
    resource.setProperties({id: 1, permissionState:'open'});
    permission.setProperties({
      permissions: {
        view: { states: ['closed'] }
      }
    });
    return can.can('view', resource).then(function(value){
      assert.equal(value, false, 'Should not be granted permission');
    });
  });
});
