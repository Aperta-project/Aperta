import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['si-file'],
  classNameBindings: ['deleteState:si-file-grey'],
  file: null,
  isEditable: false,
  deleteState: false,

  actions: {
    enterDeleteState: function() {
      this.set('deleteState', true);
    },

    delete: function() {
      this.get('file').destroyRecord();
      this.set('deleteState', false);
    },

    cancelDelete: function() {
      this.set('deleteState', false);
    }
  }
});
