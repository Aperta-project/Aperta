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
  store: Ember.inject.service(),

  build(abilityString, resource, callback) {

    let classname = resource.constructor.modelName.camelize();
    classname = classname.charAt(0).toLowerCase() + classname.slice(1);
    const permissionId =  classname + '+' + resource.id;
    const ability = Ability.create({name:abilityString, resource: resource});

    this.get('store').find('permission', permissionId).then(function(value){
      ability.set('permissions', value);
      if (callback){
        callback(ability);
      }
    });

    return ability;
  },

  can(abilityString, resource) {
    return new Promise((resolve) => {
      this.build(abilityString, resource, resolve);
    }).then(function (ability) {
      return ability.get('can');
    });
  }
});
