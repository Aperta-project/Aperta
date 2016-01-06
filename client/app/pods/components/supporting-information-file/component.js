import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['si-file'],
  classNameBindings: ['siFileState'],

  file: null,
  isEditable: false,
  uiState: 'view', // view, edit, delete
  deleteState: false,
  editState: false,

  categories: [
    'Table',
    'Data',
    'Text',
    'Figure'
  ],

  siFileState: Ember.computed('uiState', function() {
    return 'si-file-' + this.get('uiState');
  }),

  iconClass: Ember.computed('file.category', function() {
    let klass = {
       'Figure': 'fa-file-image-o',
       'Text': 'fa-file-text-o',
       'Table': 'fa-file-o',
       'Data': 'fa-file-o'
    }[this.get('file.category')];

    return klass || 'fa-file-o';
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
