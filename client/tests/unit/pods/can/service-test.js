/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import { moduleFor, test } from 'ember-qunit';
import wait from 'ember-test-helpers/wait';
import Ember from 'ember';
import { Ability } from 'tahi/pods/can/service';
const { run } = Ember;

moduleFor('service:can', 'Unit: Can Service Permissions', {
  integration: true,
  beforeEach(){
    this.store = this.container.lookup('service:store');
    let store = this.store;

    this.permission = run(function(){
      return store.createRecord('permission', {id:'paper+1'});
    });

    this.resource = run(function(){
      return store.createRecord('Paper', {id:1});
    });
  }
});

test('the underlying Ability#can updates when `resource.permissionState` changes', function(assert){
  run(() => {
    this.permission.setProperties({
      permissions: {
        view: { states: ['open'] }
      }
    });
    this.resource.setProperties({permissionState:'closed'});
  });

  let ability = Ability.create({
    name: 'view',
    resource: this.resource,
    permissions: this.permission
  });

  assert.equal(ability.get('can'), false, 'Should not be granted permission');

  return wait().then(() => {
    this.resource.setProperties({permissionState:'open'});
    assert.equal(ability.get('can'), true, 'Should be granted permission');
  }).then(() => {
    return wait().then(() => {
      this.resource.setProperties({permissionState:'closed'});
      assert.equal(ability.get('can'), false, 'Should not be granted permission');
    });
  });
});

test('permission is denied when permissions are empty', function(assert){
  assert.expect(1);
  const can = this.subject({
    container: this.container,
    store: this.store
  });

  return can.can('some_action', this.resource).then(function(value){
    assert.equal(value, false, 'Should not be granted permission');
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
