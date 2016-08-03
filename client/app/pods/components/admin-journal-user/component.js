import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  classNames: ['user-row'],

  journalRoles: null,
  userJournalRoles: Ember.computed.mapBy('model.userRoles', 'oldRole'),

  actions: {
    noOp() {
      alert('Unimplemented -- display only. Refresh to undo');
    }
  }
});
