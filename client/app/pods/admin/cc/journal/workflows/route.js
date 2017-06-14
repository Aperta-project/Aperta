import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    var journal = this.modelFor('admin.cc.journal').journal;
    var journalID = (journal && journal.get('id'));
    return Ember.RSVP.hash({
      workflows: this.store.query(
        'manuscript-manager-template',
        {'journal_id': journalID}
      ),
      journal: journal
    });
  }
});
