import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  tagName: 'tr',
  classNames: ['user-row'],
  journal: null, //passed in

  journalRoles: null, //passed-in
  userJournalRoles: Ember.computed.mapBy('model.userRoles', 'oldRole'),

  actions: {
    addRole(journalRole) {
      var user = this.get('model');
      user.set('journalRoleName', journalRole.text);
      user.set('journalId', this.get('journal.id'));
      user.save();
    },
    removeRole() {
      alert('Unimplemented Remove -- display only. Refresh to undo');
    }
  }
});
