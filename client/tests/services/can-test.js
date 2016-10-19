import { moduleFor, test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import Ember from 'ember';
const { run } = Ember;

moduleFor('service:can', 'Unit: Can Service Permissions', {
  needs: ['model:permission', 'model:paper'],
  beforeEach(){
    this.App = startApp();
    this.store = this.App.__container__.lookup('service:store');
    this.container = this.App.__container__;
    let store = this.store;

    this.permission = run(function(){
      return store.createRecord('permission', {id:'paper+1'});
    });

    this.resource = run(function(){
      return store.createRecord('Paper', {id:1});
    });
  },

  afterEach() {
    run(this.App, 'destroy');
  }
});

test('permissions update when `resource.permissionState` changes', function(assert){
  const can = this.subject({
    container: this.container,
    store: this.store
  });

  run(() => {
    // Only one (the last) of the `permissionStates` applies. WHY?
    this.resource.setProperties({permissionState:'closed'});
    this.permission.setProperties({
      permissions: {
        view: { states: ['open'] }
      }
    });
  });

  run(() => {
    can.can('view', this.resource).then(function(value){
      assert.equal(value, false, 'Should not be granted permission');
    });
  });

  run(() => {
    this.resource.setProperties({permissionState:'open'});
  });

  run(() => {
    can.can('view', this.resource).then(function(value){
      assert.equal(value, true, 'Should be granted permission');
    });
  });
});

test('permission is denied when permissions are empty', function(assert){
  assert.expect(1);
  const can = this.subject({
    container: this.container,
    store: this.store
  });

  run(()=> {
    can.can('some_action', this.resource).then(function(value){
      assert.equal(value, false, 'Should not be granted permission');
    });
  });
});

test('permission is granted when `action` is allowed', function(assert){
  assert.expect(1);

  const can = this.subject({
    container: this.container,
    store: this.store
  });

  run(()=> {
    this.permission.setProperties({
      permissions: {
        view: { states: ['*'] }
      }
    });

    can.can('view', this.resource).then(function(value){
      assert.equal(value, true, 'Should be granted permission');
    });
  });
});

test('permission is denied when `action` is not allowed', function(assert){
  assert.expect(1);

  const can = this.subject({
    container: this.container,
    store: this.store
  });

  run(()=> {
    this.permission.setProperties({
      permissions: {
        view: { states: ['*'] }
      }
    });

    can.can('edit', this.resource).then(function(value){
      assert.equal(value, false, 'Should not be granted permission');
    });
  });
});

test('permission is granted when `action` is allowed for state', function(assert){
  assert.expect(1);

  const can = this.subject({
    container: this.container,
    store: this.store
  });

  run(()=> {
    this.resource.setProperties({permissionState:'open'});
    this.permission.setProperties({
      permissions: {
        view: { states: ['open'] }
      }
    });

    can.can('view', this.resource).then(function(value){
      assert.equal(value, true, 'Should be granted permission');
    });
  });
});

test('permission is denied when `action` is not allowed for state', function(assert){
  assert.expect(1);

  const can = this.subject({
    container: this.container,
    store: this.store
  });

  run(()=> {
    this.resource.setProperties({permissionState:'open'});
    this.permission.setProperties({
      permissions: {
        view: { states: ['closed'] }
      }
    });

    can.can('view', this.resource).then(function(value){
      assert.equal(value, false, 'Should not be granted permission');
    });
  });
});
