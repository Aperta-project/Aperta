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
import { findPermissionFromList } from 'tahi/lib/admin-card-permission';

export default Ember.Service.extend({
  store: Ember.inject.service(),

  /**
   * Add a role to a permission. If the permissionAction is edit and the view
   * permission does not exist, also add the view permission.
   *
   * @method addRoleToPermissionSensible
   * @param {AdminJournalRole>} role to add permission to
   * @param {string} filterByCardId
   * @param {string} permissionAction the action for the permission, e.g. view
   * @return {Ember.Array.<CardPermission>} All permissions that were modified
   */

  editPermissions: ['edit', 'edit_discussion_footer', 'assign_others', 'be_assigned', 'manage_participant'],

  correspondingActions: {
    'edit': ['view'],
    'be_assigned': ['view', 'edit'],
    'assign_others': ['view', 'edit'],
    'edit_discussion_footer': ['view_discussion_footer'],
    'manage_participant': ['view_participants']
  },

  addRoleToPermissionSensible(role, filterByCardId, permissionAction) {
    let retval = [];
    if (this.get('editPermissions').includes(permissionAction)) {
      const correspondingActions = this.get('correspondingActions')[permissionAction];
      correspondingActions.forEach(function(correspondingAction) {
        const viewPermission = this.findPermissionOrCreate(filterByCardId, correspondingAction);
        if (viewPermission && (!viewPermission.get('roles').includes(role))) {
          retval.push(this.addRoleToPermission(role, filterByCardId, correspondingAction));
        }
      }, this);
    }
    retval.push(this.addRoleToPermission(role, filterByCardId, permissionAction));
    return retval;
  },

  /**
   * Add a role to a permission.
   *
   * @method addRoleToPermission
   * @param {AdminJournalRole>} role to add permission to
   * @param {string} filterByCardId
   * @param {string} permissionAction the action for the permission, e.g. view
   * @return {CardPermission} The permission that was modified
   */
  addRoleToPermission(role, filterByCardId, permissionAction) {
    const perm = this.findPermissionOrCreate(filterByCardId, permissionAction);
    perm.get('roles').addObject(role);
    return perm;
  },

  /**
   * Remove a role from a permission
   *
   * @method removeRoleFromPermission
   * @param {AdminJournalRole>} role to remove permission from
   * @param {string} filterByCardId
   * @param {string} permissionAction the action for the permission, e.g. view
   * @return {CardPermission} The permission that was modified
   */
  removeRoleFromPermission(role, filterByCardId, permissionAction) {
    const perm = this.findPermission(filterByCardId, permissionAction, role);
    perm.get('roles').removeObject(role);
    return perm;
  },

  /**
   * Find a permission with the given filterByCardId and permissionAction, or
   * create a new one if none exists.
   *
   * @method findPermissionOrCreate
   * @param {string} filterByCardId
   * @param {string} permissionAction the action for the permission, e.g. view
   * @param {Ember.Object.<Role>} role optional the role of the permission
   * @return {CardPermission} The permission that was found or created
   */
  findPermissionOrCreate(filterByCardId, permissionAction, role) {
    const perm = this.findPermission(filterByCardId, permissionAction);
    if (perm) {
      return perm;
    } else {
      return this.get('store').createRecord('card-permission', {
        roles: [],
        filterByCardId: filterByCardId,
        permissionAction: permissionAction
      });
    }
  },

  /**
   * Find a permission with the given filterByCardId and permissionAction.
   *
   * @method findPermission
   * @param {string} filterByCardId
   * @param {string} permissionAction the action for the permission, e.g. view
   * @param {Ember.Object.<Role>} role optional the role of the permission
   * @return {CardPermission} The permission that was found, or undefined if nothing found
   */
  findPermission(filterByCardId, permissionAction, role) {
    const perms = this.get('store').peekAll('card-permission');
    return findPermissionFromList(perms, filterByCardId, permissionAction, role);
  }
});
