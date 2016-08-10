import Ember from 'ember';

/**
  A fake CanService used for testing.

  @extends Ember.Object
  @class FakeCanService
*/
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

  /**
    Returns an `Ember.Object` class that, when instantiated, will duplicate the
    permissions of the current object.

    This is helpful when you need an object to be registered as a service in an
    ember qunit test.

    Example usage:
    ```javascript

    test('the right thing', function(assert) {
      const can = FakeCanService.create().allowPermission('rescind_decision', paper);
      this.register('service:can', can.asService());
      ...
    });
    ```

    This seems to be the only way to register a service in ember qunit test:
    that is, by providing a class and not a instance.

    If you find a better way, perhaps remove this.

    @method asService
    @return {Ember.Object} An Object that subclasses `FakeCanService`
  */
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
