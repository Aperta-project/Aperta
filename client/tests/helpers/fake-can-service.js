import Ember from 'ember';

const FakeCanService = Ember.Object.extend({
  init: function(){
    this._super(...arguments);
    this.allowedPermissions = {};
  },

  can(permission, resource){
    return new Ember.RSVP.Promise( (resolve, reject) => {
      resolve(this.allowedPermissions[permission] === resource);
    });
  },

  build(permission, resource) {
    var permissions = this.allowedPermissions;
    var Ability = Ember.Object.extend({
      can: Ember.computed(function(){
        return permissions[permission] === resource;
      })
    });

    return Ability.create({});
  },

  allowPermission(permission, resource){
    this.allowedPermissions[permission] = resource;
    return this;
  },

  rejectPermission(permission){
    delete this.allowedPermissions[permission];
    return this;
  },

  asService() {
    const allowedPermissions = this.allowedPermissions;
    return FakeCanService.extend({
      init() {
        this._super(...arguments);
        this.allowedPermissions = allowedPermissions;
      }
    });
  }
});

export default FakeCanService;


