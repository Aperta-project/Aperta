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
  addRoleToPermissionSensible(role, filterByCardId, permissionAction) {
    let retval = [];
    if (permissionAction === 'edit') {
      const viewPermission = this.findPermissionOrCreate(filterByCardId, 'view');
      if (viewPermission && (!viewPermission.get('roles').includes(role))) {
        retval.push(this.addRoleToPermission(role, filterByCardId, 'view'));
      }
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
    const perm = this.findPermission(filterByCardId, permissionAction);
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
   * @return {CardPermission} The permission that was found or created
   */
  findPermissionOrCreate(filterByCardId, permissionAction) {
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
   * @return {CardPermission} The permission that was found, or undefined if nothing found
   */
  findPermission(filterByCardId, permissionAction) {
    const perms = this.get('store').peekAll('card-permission');
    return findPermissionFromList(perms, filterByCardId, permissionAction);
  }
});
