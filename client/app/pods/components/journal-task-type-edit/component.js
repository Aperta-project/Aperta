import Ember from 'ember';

const { computed } = Ember;

export default Ember.Component.extend({
  classNames: ['individual-task-type'],

  roles: null,

  selectedRole: computed('model.role', function() {
    const role = this.get('availableTaskRoles')
                     .findBy('kind', this.get('model.role'));

    if(Ember.isEmpty(role)) { return null; }

    return {
      id: role.get('id'),
      text: role.get('name')
    };
  }),

  journalRoleSort: ['name: asc'],
  availableTaskRoles: computed.sort('roles', 'journalRoleSort'),

  formattedTaskRoles: computed('availableTaskRoles.[]', function() {
    return this.get('availableTaskRoles').map(function(taskRole) {
      return {
        id: taskRole.get('id'),
        text: taskRole.get('name')
      };
    });
  }),

  actions: {
    clearRole() {
      this.set('model.role', null);
      this.get('model').save();
    },

    save(roleProxy) {
      const kind = this.get('availableTaskRoles')
                       .findBy('name', roleProxy.text)
                       .get('kind');

      this.set('model.role', kind);
      this.get('model').save();
    }
  }
});
