import Ember from 'ember';

export default Ember.Component.extend({
  journal: null, //passed in

  journalRoles: null, //passed-in

  actions: {
    addRole(journalRole) {
      var user = this.get('user');
      user.setProperties({
        journalRoleName: journalRole.text,
        modifyAction: 'add-role',
        journalId: this.get('journal.id')
      });
      user.save();
    },
    removeRole(journalRole) {
      var user = this.get('user');
      user.setProperties({
        journalRoleName: journalRole.text,
        modifyAction: 'remove-role',
        journalId: this.get('journal.id')
      });
      user.save();
    }
  }
});
