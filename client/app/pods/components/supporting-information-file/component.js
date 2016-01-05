import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['si-file'],
  classNameBindings: ['siFileState'],

  file: null,
  isEditable: false,
  uiState: 'view', // view, edit, delete
  deleteState: false,
  editState: false,

  siFileState: Ember.computed('uiState', function(){
    return 'si-file-' + this.get('uiState');
  }),

  actions: {
    enterDeleteState: function() {
      this.set('uiState', 'delete');
    },

    delete: function() {
      this.get('file').destroyRecord();
      this.set('uiState', 'view');
    },

    cancelDelete: function() {
      this.set('uiState', 'view');
    },

    enterEditState: function() {
      this.set('uiState', 'edit');
    },

    cancelEdit: function(){
      this.get('file').rollback();
      this.set('uiState', 'view');
    },

    saveEdit: function(){
      this.get('file').save();
      this.set('uiState', 'view');
    }

  }
});
