import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['admin-tab-bar'],
  can: Ember.inject.service(),

  canAdminJournal: Ember.computed(function() {
    let journal = this.get('journal');
    let journalTerm = journal ? journal : 'Journal';
    return this.get('can').can('administer', journalTerm);
  }),
});
