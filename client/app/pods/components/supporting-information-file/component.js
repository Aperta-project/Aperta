import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['si-file'],
  classNameBindings: ['siFileState'],

  file: null,
  isEditable: false,
  uiState: 'view', // view, edit, delete
  deleteState: false,
  editState: false,

  fileLabel:null,
  fileCategory:null,
  fileTitle:null,
  fileCaption:null,
  filePublishable:null,

  loadFileAttrs: function(){
    this.setProperties({
      fileLabel: this.get('file.label'),
      fileCategory: this.get('file.category'),
      fileTitle: this.get('file.title'),
      fileCaption: this.get('file.caption'),
      filePublishable: this.get('file.publishable')
    });
  },

  saveFileAttrs: function(){
    this.setProperties({
      'file.label': this.get('fileLabel'),
      'file.category': this.get('fileCategory'),
      'file.title': this.get('fileTitle'),
      'file.caption': this.get('fileCaption'),
      'file.publishable': this.get('filePublishable')
    });
    this.get('file').save();
  },

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
      this.loadFileAttrs()
      this.set('uiState', 'edit');
    },

    cancelEdit: function(){
      this.set('uiState', 'view');
    },

    saveEdit: function(){
      this.saveFileAttrs();
      this.set('uiState', 'view');
    }

  }
});
