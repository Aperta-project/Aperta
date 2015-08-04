import Ember from 'ember';

export default Ember.ArrayController.extend(Ember.SortableMixin, {
  sortProperties: ['isNew', 'name'],
  sortAscending: false,

  newJournalPresent: Ember.computed('arrangedContent.@each.isNew', function() {
    return this.get('arrangedContent').any((a) => a.get('isNew'));
  }),

  actions: {
    addNewJournal() {
      if (!this.get('newJournalPresent')) {
        this.store.createRecord('admin-journal');
      }
    }
  }
});
