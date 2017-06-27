import Ember from 'ember';

export default Ember.Controller.extend({
  adminCardPermission: Ember.inject.service(),

  actions: {
    turnOnPermission(role, card, permissionAction) {
      const service = this.get('adminCardPermission');
      const cardId = card.get('id');
      const perms = service.addRoleToPermissionSensible(role, cardId, permissionAction);
      Ember.RSVP.all(perms.map((p)=>p.save())).catch(() => {
        // rollbackAttributes does not work with hasMany
        perms.map((p)=>p.get('roles').removeObject(role));
      });
    },

    turnOffPermission(role, card, permissionAction) {
      const service = this.get('adminCardPermission');
      const cardId = card.get('id');
      const perm = service.removeRoleFromPermission(role, cardId, permissionAction);
      perm.save().catch(() => {
        // rollbackAttributes does not work with hasMany
        perm.addObject(role);
      });
    }
  }
});
