import Ember from 'ember';
import { findPermissionFromList } from 'tahi/lib/admin-card-permission';

export default Ember.Service.extend({
  store: Ember.inject.service(),

  findPermissionOrCreate(card, permissionAction) {
    const perm = this.findPermission(card, permissionAction);
    if (perm) {
      return perm;
    } else {
      return this.get('store').createRecord('card-permission', {
        roles: [],
        filterByCardId: card.id,
        permissionAction: permissionAction
      });
    }
  },

  findPermission(card, permissionAction) {
    const perms = this.get('store').peekAll('card-permission');
    return findPermissionFromList(perms, card.get('id'), permissionAction);
  }
});
