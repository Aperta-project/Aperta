import Ember from 'ember';

export default Ember.ArrayController.extend(Ember.SortableMixin, {
  sortProperties: ['isNew', 'name'],
  sortAscending: false,

  newJournalPresent: function() {
    return this.get('arrangedContent').any((a) => a.get('isNew'));
  }.property('arrangedContent.@each.isNew'),

  actions: {
    addNewJournal() {
      if (!this.get('newJournalPresent')) {
        this.store.createRecord('adminJournal');
      }
    }
  }
});
