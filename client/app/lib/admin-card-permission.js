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

    if (!isMatch) {
      return false;
    } else {
      if (perm.id === "596" || perm.id === "597" || perm.id === "598" ) {
        // debugger
      }
    }

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
