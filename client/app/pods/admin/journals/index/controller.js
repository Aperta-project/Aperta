import Ember from 'ember';

export default Ember.Controller.extend({
  sortProperties: ['isNew:desc', 'id:desc'],
  arrangedContent: Ember.computed.sort('model', 'sortProperties'),

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
