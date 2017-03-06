import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    const journal = this.modelFor('admin.cc.journals').journal;
    const cards = journal ? journal.get('cards') : this.store.findAll('card');
    return Ember.RSVP.hash({
      cards: cards,
      journal: journal
    });
  }
});
