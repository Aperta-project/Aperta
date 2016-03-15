import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';

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
  build(abilityString, resource, callback) {

    this.set('store', getOwner(this).lookup('store:main'));
    let classname = resource.constructor.typeKey;
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
