import Ember from 'ember';

const { computed } = Ember;

export default Ember.Component.extend({
  classNames: ['individual-task-type'],

  selectedOldRole: null,

  availableTaskRoles: [],

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
      this.get('model').save();
    },

    save(roleProxy) {
      this.get('model').save();
    }
  }
});
