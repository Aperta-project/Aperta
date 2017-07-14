import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    var journal = this.modelFor('admin.journals').journal;
    var journalID = (journal && journal.get('id'));

    if (journalID) {
      return Ember.RSVP.hash({
        users: this.store.query('admin-journal-user', {
          'journal_id': journalID
        }),
        roles: journal.get('adminJournalLevelRoles'),
        journal: journal
      });

    } else {
      return {};
    }
  }
});
