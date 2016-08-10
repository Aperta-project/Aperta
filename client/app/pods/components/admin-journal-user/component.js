import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  tagName: 'tr',
  classNames: ['user-row'],
  journal: null, //passed in

  journalRoles: null, //passed-in
  userJournalRoles: Ember.computed.mapBy('user.userRoles', 'oldRole'),

  actions: {
    addRole(journalRole) {
      var user = this.get('user');
      user.set('journalRoleName', journalRole.text);
      user.set('modifyAction', 'add-role');
      user.set('journalId', this.get('journal.id'));
      user.save();
    },
    removeRole(journalRole) {
      var user = this.get('user');
      user.set('journalRoleName', journalRole.text);
      user.set('modifyAction', 'remove-role');
      user.set('journalId', this.get('journal.id'));
      user.save();
    }
  }
});
