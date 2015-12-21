import Ember from 'ember';

const { computed } = Ember;

export default Ember.Component.extend({
  classNames: ['individual-task-type'],

  oldRoles: null,

  selectedOldRole: computed('model.oldRole', function() {
    const oldRole = this.get('availableTaskRoles')
                     .findBy('kind', this.get('model.oldRole'));

    if(Ember.isEmpty(oldRole)) { return null; }

    return {
      id: oldRole.get('id'),
      text: oldRole.get('name')
    };
  }),

  journalRoleSort: ['name: asc'],
  availableTaskRoles: computed.sort('oldRoles', 'journalRoleSort'),

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
      this.set('model.oldRole', null);
      this.get('model').save();
    },

    save(roleProxy) {
      const kind = this.get('availableTaskRoles')
                       .findBy('name', roleProxy.text)
                       .get('kind');

      this.set('model.oldRole', kind);
      this.get('model').save();
    }
  }
});
