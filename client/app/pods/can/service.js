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

import Ember from 'ember';

export var Ability = Ember.Object.extend({
  name: null,
  resource: null,
  permissions:null,

  can: Ember.computed('name', 'resource', 'resource.permissionState', 'permissions', function(){
    if (!this.get('permissions')){
      return false;
    }
    var permissionHash = this.get('permissions.permissions');
    if (!permissionHash){
      return false;
    }

    var states = permissionHash[this.get('name')];
    if (!states){
      return false;
    }

    states = states.states;
    if (states.includes('*')){
      return true;
    }

    return states.includes(this.get('resource.permissionState'));
  })
});

export default Ember.Service.extend({
  store: Ember.inject.service(),

  build(abilityString, resource, callback) {
    let classname;
    if (resource.permissionModelName) {
      classname = resource.permissionModelName;
    } else {
      classname = resource.constructor.modelName.camelize();
      classname = classname.charAt(0).toLowerCase() + classname.slice(1);
    }
    const permissionId =  classname + '+' + resource.id;
    const ability = Ability.create({name:abilityString, resource: resource});

    this.get('store').find('permission', permissionId).then(function(value){
      ability.set('permissions', value);
      if (callback){
        callback(ability);
      }
    });

    return ability;
  },

  can(abilityString, resource) {
    return new Promise((resolve) => {
      this.build(abilityString, resource, resolve);
    }).then(function (ability) {
      return ability.get('can');
    });
  }
});
