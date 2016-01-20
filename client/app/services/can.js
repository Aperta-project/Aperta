import Ember from 'ember';
import { CanService } from 'ember-can';

export default CanService.extend({
  build(abilityString, resource, properties) {
    const abilityName = 'ability:permissions';
    const ability = this.container.lookup(abilityName);
    this.store = this.container.lookup('store:main');

    Ember.assert('No ability type found for ' + abilityName, ability);

    // see if we've been given properties instead of resource
    if (!properties && resource && !(resource instanceof Ember.Object)) {
      properties = resource;
      resource   = null;
    }

    Ember.assert('No resource provided. Must provide resource when checking permissions.', resource);

    if (resource) {
      ability.set('model', resource);
    }

    if (properties) {
      ability.setProperties(properties);
    }

    ability.set('action', abilityString);
    var permissionId = resource.constructor.typeKey + '+' + resource.id;
    var permission = this.store.find('permission', permissionId);

    Ember.assert('No Permission provided. Permission must be set', permission);

    ability.set('data', permission.get('permissions'));

    return ability;
  },

  can(abilityString, resource, properties) {
    const ability = this.build(abilityString, resource, properties);
    return ability.get('can');
  }
});
