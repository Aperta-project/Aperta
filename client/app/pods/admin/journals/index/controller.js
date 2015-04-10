import Ember from 'ember';

export default Ember.Controller.extend(Ember.SortableMixin, {
  newJournalPresent: function() {
    this.get('arrangedContent').any((a) => a.get('isNew'));
  }.property('arrangedContent.@each.isNew'),

  actions: {
    addNewJournal() {
      if (!this.get('newJournalPresent')) {
        this.store.createRecord('adminJournal');
      }
    }
  }
});
