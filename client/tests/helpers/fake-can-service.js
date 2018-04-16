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

/**
  A fake CanService used for testing.

  @extends Ember.Object
  @class FakeCanService
*/
const FakeCanService = Ember.Object.extend({
  init: function(){
    this._super(...arguments);
    this.allowedPermissions = {};
  },

  can(permission, resource){
    return new Ember.RSVP.Promise((resolve) => {
      let permissionVal = this.allowedPermissions[permission];

      if (permissionVal === '*') {
        resolve(true);
      } else {
        resolve(this.allowedPermissions[permission] === resource);
      }
    });
  },

  build(permission, resource) {
    var permissions = this.allowedPermissions;
    var Ability = Ember.Object.extend({
      can: Ember.computed(function(){
        return permissions[permission] === resource;
      })
    });

    return Ability.create({});
  },

  /**
   * Calling allowPermission on an instance of the service is the way
   * to add permissions.
  */
  allowPermission(permission, resource){
    this.allowedPermissions[permission] = resource;
    return this;
  },

  rejectPermission(permission){
    delete this.allowedPermissions[permission];
    return this;
  },

  /**
    Returns an `Ember.Object` class that, when instantiated, will duplicate the
    permissions of the current object.

    This is helpful when you need an object to be registered as a service in an
    ember qunit test.

    Example usage:
    ```javascript

    test('the right thing', function(assert) {
      const can = FakeCanService.create().allowPermission('rescind_decision', paper);
      this.register('service:can', can.asService());
      ...
    });
    ```

    This seems to be the only way to register a service in ember qunit test:
    that is, by providing a class and not a instance.

    If you find a better way, perhaps remove this.

    @method asService
    @return {Ember.Object} An Object that subclasses `FakeCanService`
  */
  asService() {
    const allowedPermissions = this.allowedPermissions;
    return FakeCanService.extend({
      init() {
        this._super(...arguments);
        this.allowedPermissions = allowedPermissions;
      }
    });
  }
});

export default FakeCanService;
