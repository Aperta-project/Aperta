import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    addRole() {
      this.get('model').addObject(this.store.createRecord('role'));
    },

    deleteRole(role) {
      role.destroyRecord();
    }
  }
});
