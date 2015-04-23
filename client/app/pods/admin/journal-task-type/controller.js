import Ember from 'ember';

export default Ember.Controller.extend({
  needs: ['admin/journal'],
  journal: Ember.computed.alias('controllers.admin/journal.model'),
  journalRoleSort: ['name: asc'],
  availableTaskRoles: Ember.computed.sort('journal.roles', 'journalRoleSort'),

  actions: {
    save() {
      this.get('model').save().then()["catch"](function() {});
    },

    cancel() {
      if (this.get('model.isNew')) {
        this.get('model').deleteRecord();
      } else {
        this.get('model').rollback();
      }
    },

    delete() {
      this.send('deleteRole', this.get('model'));
    }
  }
});
