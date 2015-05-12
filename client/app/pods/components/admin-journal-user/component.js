import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  classNames: ['user-row'],

  journalRoles: null,
  userJournalRoles: Ember.computed.mapBy('model.userRoles', 'role'),

  selectableJournalRoles: function() {
    return this.get('journalRoles').map(function(jr) {
      return {
        id: jr.get('id'),
        text: jr.get('name')
      };
    });
  }.property('journalRoles'),

  selectableUserJournalRoles: function() {
    return this.get('userJournalRoles').map(function(jr) {
      return {
        id: jr.get('id'),
        text: jr.get('name')
      };
    });
  }.property('userJournalRoles'),

  actions: {
    removeRole(roleObj) {
      this.get('model.userRoles').findBy('role.id', roleObj.id).destroyRecord();
    },

    assignRole(roleObj) {
      this.sendAction('assignRole', roleObj.id, this.get('model'));
    }
  }
});
