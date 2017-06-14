import Ember from 'ember';

export default Ember.Route.extend({
  setupController(controller, model) {
    this._super(controller, model);
    this.fetchAdminJournalUsers(model.get('id'));
  },

  deactivate() {
    this.set('controller.adminJournalUsers', null);
  },

  fetchAdminJournalUsers(journalId) {
    return this.store.query('admin-journal-user', {
      journal_id: journalId
    }).then((users)=> {
      this.set('controller.adminJournalUsers', users);
    });
  }
});
