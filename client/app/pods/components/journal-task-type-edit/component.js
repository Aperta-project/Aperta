import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['individual-task-type'],

  roles: null,
  journalRoleSort: ['name: asc'],
  availableTaskRoles: Ember.computed.sort('roles', 'journalRoleSort'),

  actions: {
    save() {
      this.get('model').save().then(function(){}, function() {});
    }
  }
});
