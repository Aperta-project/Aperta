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
 * Return the first permission where the permissionAction matches and the
 * filterByCardId matches the cardId.
 *
 * @method findPermissionFromList
 * @param {Ember.Array.<CardPermission>} permissions to
 * @param {string} filterByCardId to check for
 * @param {string} permissionAction the action for the permission, e.g. view
 * @param {Ember.Object.<Role>} role optional the role of the permission
 * @return {Object} Found permission or undefined
*/
export function findPermissionFromList(permissions, filterByCardId, permissionAction, role) {
  return permissions.find((perm)=>{
    var isMatch = (
      (perm.get('permissionAction') === permissionAction) &&
      (perm.get('filterByCardId') === filterByCardId)
    );

    if (!isMatch) { return false; }

    //any permission removal should pass in a role
    if (role) {
      return perm.get('roles').filterBy('id', role.id).length > 0;
    } else {
      return true;
    }
  });
}

/**
 * Ember helper to create a computed property that returns true if a permission
 * exists where the filterByCardId equals the id of the cardKey card for the
 * given roleKey role with the correct permissionAction
 *
 * @method permissionExists
 * @param {string} cardKey to use to look up card on object
 * @param {string} roleKey to use to look up role on object
 * @param {string} permissionAction the action for the permission, e.g. view
 * @return {Function}
*/

export function permissionExists(cardKey, roleKey, permissionAction) {
  return Ember.computed(cardKey, `${roleKey}.cardPermissions.[]`, function() {
    return !Ember.isEmpty(findPermissionFromList(
      this.get(`${roleKey}.cardPermissions`), this.get(cardKey).get('id'), permissionAction));
  });
}
