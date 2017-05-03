import Ember from 'ember';

/**
 * Return the first permission where the permissionAction matches and the
 * filterByCardId matches the cardId.
 *
 * @method findPermissionFromList
 * @param {Ember.Array.<CardPermission>} permissions to
 * @param {string} filterByCardId to check for
 * @param {string} permissionAction the action for the permission, e.g. view
 * @return {Object} Found permission or undefined
*/
export function findPermissionFromList(permissions, filterByCardId, permissionAction) {
  return permissions.find((perm)=>{
    return ((perm.get('permissionAction') === permissionAction) &&
            (perm.get('filterByCardId') === filterByCardId));
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
