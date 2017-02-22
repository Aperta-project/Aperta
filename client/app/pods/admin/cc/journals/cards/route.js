import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    var journal = this.modelFor('admin.cc.journals').journal;
    var journalID = (journal && journal.get('id'));

    return Ember.RSVP.hash({
      cards: this.store.query(
        'card',
        {'journal_id': journalID}
      ),
      journal: journal
    });
  }
});
