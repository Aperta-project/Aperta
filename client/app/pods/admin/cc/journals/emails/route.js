import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    var journal = this.modelFor('admin.cc.journals').journal;
    var journalID = (journal && journal.get('id'));
    return Ember.RSVP.hash({
      templates: this.store.query(
        'letter-template',
        {'journal_id': journalID}
      ),
      journal: journal
    });
  }
});
