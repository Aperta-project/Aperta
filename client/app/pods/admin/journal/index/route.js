import Ember from 'ember';

export default Ember.Route.extend({
  setupController(controller, model) {
    this._super(controller, model);
    controller.set(
      'doiStartNumberEditable',
      Ember.isEmpty(model.get('firstDoiNumber'))
    );
    this.fetchAdminJournalUsers(model.get('id'));
  },

  deactivate() {
    this.set('controller.adminJournalUsers', null);
    return this.set('controller.doiEditState', false);
  },

  fetchAdminJournalUsers(journalId) {
    return this.store.find('admin-journal-user', {
      journal_id: journalId
    }).then((users)=> {
      this.set('controller.adminJournalUsers', users);
    });
  }
});
