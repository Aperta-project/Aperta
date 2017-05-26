import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    var journal = this.modelFor('admin.cc.journals').journal;
    var journalID = (journal && journal.get('id'));
    var params = {'journal_id': journalID};
    return Ember.RSVP.hash({
      // only retrieve letter templates if there's a journal
      templates: journalID ? this.store.query('letter-template', params) : [],
      journal: journal
    });
  }
});
