import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  classNames: ['user-row'],

  journalRoles: null,
  userJournalRoles: Ember.computed.mapBy('model.userRoles', 'oldRole'),

  selectableJournalRoles: Ember.computed('journalRoles.[]', function() {
    return this.get('journalRoles').map(function(jr) {
      return {
        id: jr.get('id'),
        text: jr.get('name')
      };
    });
  }),

  selectableUserJournalRoles: Ember.computed('userJournalRoles.[]', function() {
    return this.get('userJournalRoles').map(function(jr) {
      return {
        id: jr.get('id'),
        text: jr.get('name')
      };
    });
  }),

  actions: {
    removeOldRole(oldRoleObj) {
      this.get('model.userRoles').findBy('oldRole.id', oldRoleObj.id).destroyRecord();
    },

    assignOldRole(oldRoleObj) {
      this.sendAction('assignOldRole', oldRoleObj.id, this.get('model'));
    }
  }
});
