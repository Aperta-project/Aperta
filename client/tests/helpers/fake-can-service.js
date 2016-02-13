import Ember from 'ember';

export default Ember.Object.extend({
  init: function(){
    this._super(...arguments);
    this.allowedPermissions = {};
  },

  // every body gets permission by default
  can: function(permission, resource){
    return new Ember.RSVP.Promise( (resolve, reject) => {
      resolve(this.allowedPermissions[permission] === resource);
    });
  },

  allowPermission: function(permission, resource){
    this.allowedPermissions[permission] = resource;
    return this;
  },

  rejectPermission: function(permission, resource){
    delete this.allowedPermissions[permission];
    return this;
  }
});
