import { moduleFor, test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import Ember from 'ember';
import DS from 'ember-data';

moduleFor('ability:permissions', 'Unit: Authorization Permissions', {
  beforeEach(){
    this.App = startApp();
    this.App.DummyModel = DS.Model.extend();
    this.store = this.App.__container__.lookup('store:main');

    let store = this.store;
    this.resource = Ember.run(function(){
      return store.createRecord('dummy-model');
    });
  },

  afterEach: function() {
    Ember.run(this.App, 'destroy');
  }
});

test(`permission is granted for client-side created objects which have no id
since they were created by the user`,
function(assert) {
  let ability = this.subject();
  let resource = this.resource;

  assert.notOk(resource.get('id'), 'should not have an id');
  Ember.run(function(){
    ability.setProperties({
      model: resource,
      action: 'view'
    });
  });
  assert.equal(ability.get('can'), true, 'should be granted permission');
});

test(`permission is denied for objects with an id as they are assumed to be
owned by the server (thus requiring permissions)`,
function(assert) {
  let ability = this.subject();
  let resource = this.resource;

  Ember.run(function(){
    resource.set('id', 99);
    ability.setProperties({
      model: resource,
      action: 'view'
    });
  });
  assert.equal(ability.get('can'), false, 'should NOT be granted permission');
});

test(`permission is denied when the resource being checked doesn't have the
requested action as a permissible action`,
function(assert) {
  let ability = this.subject();
  let resource = this.resource;

  Ember.run(function(){
    resource.setProperties({ id: 2 });
    ability.setProperties({
      model: resource,
      action: 'destroy',
      data: [
        {
          object: { id: 2, type: 'DummyModel' },
          permissions: {
            view: { states: ['*'] }
          }
        }
      ]
    });
  });
  assert.equal(ability.get('can'), false, '#destroy should not be granted');
});


test(`permission is granted when resource being checked is eligible for the
action and any permission state`,
function(assert) {
  let ability = this.subject();
  let resource = this.resource;

  Ember.run(function(){
    resource.setProperties({ id: 2 });
    ability.setProperties({
      model: resource,
      action: 'view',
      data: [
        {
          object: { id: 2, type: 'DummyModel' },
          permissions: {
            view: { states: ['*'] }
          }
        }
      ]
    });
  });
  assert.equal(ability.get('can'), true, 'should be granted permission');
});

test(`permission is granted when resource being checked is eligible for the
action and the current object's state`,
function(assert) {
  let ability = this.subject();
  let resource = this.resource;

  Ember.run(function(){
    resource.setProperties({
      id: 2,
      state: 'published'
    });
    ability.setProperties({
      model: resource,
      action: 'view',
      data: [
        {
          object: { id: 2, type: 'DummyModel' },
          permissions: {
            view: { states: ['published'] }
          }
        }
      ]
    });
  });
  assert.equal(ability.get('can'), true, 'should be granted permission');
});

test(`permission is denied when resource being checked is eligible for the
action BUT NOT the current object's state`,
function(assert) {
  let ability = this.subject();
  let resource = this.resource;

  Ember.run(function(){
    resource.setProperties({
      id: 2,
      state: 'in_revision'
    });
    ability.setProperties({
      model: resource,
      action: 'view',
      data: [
        {
          object: { id: 2, type: 'DummyModel' },
          permissions: {
            view: { states: ['published'] }
          }
        }
      ]
    });
  });
  assert.equal(ability.get('can'), false, 'should not be granted permission');
});

test(`allow the resource to use a different property than 'state' to
match up to the permission states`,
function(assert) {
  let ability = this.subject();
  let resource = this.resource;

  Ember.run(function(){
    resource.setProperties({
      id: 2,
      publishingState: 'published',
      statePropertyForPermissions: Ember.computed(function(){
        return 'publishingState';
      })
    });
    ability.setProperties({
      model: resource,
      action: 'view',
      data: [
        {
          object: { id: 2, type: 'DummyModel' },
          permissions: {
            view: { states: ['published'] }
          }
        }
      ]
    });
  });
  assert.equal(ability.get('can'), true, 'should be granted permission');
});
