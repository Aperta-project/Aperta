import Ember from 'ember';

var Ability = Ember.Object.extend({
  name: null,
  resource: null,
  permissions:null,

  can: Ember.computed('name', 'resource', 'permissions', function(){
    if (!this.get('permissions')){
      return false;
    }
    var permissionHash = this.get('permissions.permissions');
    if (!permissionHash){
      return false;
    }

    var states = permissionHash[this.get('name')];
    if (!states){
      return false;
    }

    states = states.states;
    if (states.contains('*')){
      return true;
    }

    return states.contains(this.get('resource.permissionState'));
  })
});

export default Ember.Service.extend({
  build(abilityString, resource, promise) {

    this.store = this.container.lookup('store:main');

    var permissionId = resource.constructor.typeKey + '+' + resource.id;
    var ability = Ability.create({name:abilityString, resource: resource});

    this.store.find('permission', permissionId).then(function(value){
      ability.set('permissions', value);
      if (promise){
        promise.resolve();
      }
    });

    return ability;
  },

  can(abilityString, resource) {
    var ability
    var abilityPromise =  new Promise((resolve, reject)=> {
      var promise = {resolve: resolve, reject: reject};
      ability = this.build(abilityString, resource, promise);
    });
    return abilityPromise.then(function (value) {
      return ability.get('can');
    })
  }
});
