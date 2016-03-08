import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['paper-tracker-query'],
  query: null,
  editState: false,

  actions: {
    delete() {
      this.get('query').destroyRecord();
    },

    startEditTitle() {
      this.set('editState', true);
    },

    saveTitle() {
      this.get('query').save();
      this.set('editState', false);
    }
  }
});
