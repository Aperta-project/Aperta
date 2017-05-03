import Ember from 'ember';

export default Ember.Controller.extend({
  adminCardPermission: Ember.inject.service(),

  actions: {
    turnOnPermission(role, card, permissionAction) {
      const perm = this.get('adminCardPermission').findPermissionOrCreate(card, permissionAction);
      perm.get('roles').addObject(role);
      perm.save().catch(() => {
        // rollbackAttributes does not work with hasMany
        if (perm.get('isNew')) {
          perm.deleteRecord();
        } else {
          perm.get('roles').removeObject(role);
        }
      });
    },

    turnOffPermission(role, card, permissionAction) {
      const perm = this.get('adminCardPermission').findPermission(card, permissionAction);
      perm.get('roles').removeObject(role);
      perm.save().catch(() => {
        // rollbackAttributes does not work with hasMany
        perm.get('roles').addObject(role);
      });
    }
  }
});
