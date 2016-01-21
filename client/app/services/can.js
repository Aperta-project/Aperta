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
  build(abilityString, resource) {

    this.store = this.container.lookup('store:main');

    var permissionId = resource.constructor.typeKey + '+' + resource.id;
    var ability = Ability.create({name:abilityString, resource: resource});

    this.store.find('permission', permissionId).then(function(value){
      ability.set('permissions', value);
    });

    return ability;
  },

  can(abilityString, resource) {
    var ability = this.build(abilityString, resource);
    return ability.get('can');
  }
});
