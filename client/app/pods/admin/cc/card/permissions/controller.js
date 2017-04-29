import Ember from 'ember';

export default Ember.Controller.extend({
  getPermission(card, permissionAction) {
    return this.store.peekAll('card-permission').find((perm)=>{
      return perm.get('permissionAction') === permissionAction &&
        perm.get('filterByCardId') === card.get('id');
    });
  },

  actions: {
    turnOnPermission(role, card, permissionAction) {
      const perm = this.getPermission(card, permissionAction);
      if (!perm) {
        this.store.createRecord('card-permission', {
          roles: [role],
          filterByCardId: card.id,
          permissionAction: permissionAction
        }).save().catch(() => perm.destroyRecord());
      } else {
        perm.get('roles').addObject(role);
        perm.save().catch(() => {
          // rollbackAttributes does not work with hasMany
          perm.get('roles').removeObject(role);
        });
      }
    },

    turnOffPermission(role, card, permissionAction) {
      const perm = this.getPermission(card, permissionAction);
      perm.get('roles').removeObject(role);
      perm.save().catch(() => {
        // rollbackAttributes does not work with hasMany
        perm.get('roles').addObject(role);
      });
    }
  }
});
