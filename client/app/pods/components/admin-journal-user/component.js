import Ember from 'ember';

export default Ember.Component.extend({
  tagName: '',
  journal: null,

  journalRoles: null,

  actions: {
    addRole(journalRole) {
      this.setRole(journalRole, 'add');
    },
    removeRole(journalRole) {
      this.setRole(journalRole, 'remove');
    },
    displayDialog() {
      this.sendAction('displayDialog');
    }
  },

  setRole: function (role, verb) {
    var user = this.get('user');
    user.setProperties({
      journalRoleName: role.text,
      modifyAction: `${verb}-role`,
      journalId: this.get('journal.id')
    });
    user.save();
  }
});
