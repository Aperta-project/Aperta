import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['individual-task-type'],

  roles: null,

  selectedRole: Ember.computed('model.role', function() {
    let role = this.get('availableTaskRoles').findBy('kind', this.get('model.role'));

    if(Ember.isEmpty(role)) { return null; }

    return {
      id: role.get('id'),
      text: role.get('name')
    };
  }),

  journalRoleSort: ['name: asc'],
  availableTaskRoles: Ember.computed.sort('roles', 'journalRoleSort'),

  formattedTaskRoles: function() {
    return this.get('availableTaskRoles').map(function(taskRole) {
      return {
        id: taskRole.get('id'),
        text: taskRole.get('name')
      };
    });
  }.property('availableTaskRoles.@each'),

  actions: {
    save(roleProxy) {
      let role = this.get('availableTaskRoles').findBy('name', roleProxy.text);
      this.set('model.role', role.get('kind'));
      this.get('model').save();
    }
  }
});
