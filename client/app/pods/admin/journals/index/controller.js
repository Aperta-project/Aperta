import Ember from 'ember';

export default Ember.ArrayController.extend(Ember.SortableMixin, {
  sortProperties: ['isNew', 'id'],
  sortAscending: false,

  newJournalPresent: Ember.computed('arrangedContent.[]', function() {
    return this.get('arrangedContent').isAny('isNew', true);
  }),

  actions: {
    addNewJournal() {
      if (!this.get('newJournalPresent')) {
        this.store.createRecord('admin-journal');
      }
    }
  }
});
