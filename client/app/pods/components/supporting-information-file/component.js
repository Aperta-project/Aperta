import Ember from 'ember';

const { Component, computed } = Ember;

export default Component.extend({
  classNames: ['si-file'],
  classNameBindings: ['uiStateClass'],
  file: computed.alias('model.object'),
  isEditable: false, // passed-in
  uiState: 'view', // view, edit, delete
  errorsPresent: computed.alias('model.errorsPresent'),

  isEditing: computed('errorsPresent', 'uiState', function(){
    if (this.get('errorsPresent')) {
      this.set('uiState', 'edit');
      return true;
    }

    if (this.get('uiState') === 'edit') { return true; }

    return false;
  }),

  categories: [
    'Table',
    'Data',
    'Text',
    'Figure'
  ],

  uiStateClass: computed('uiState', function() {
    return `si-file-${this.get('uiState')}`;
  }),

  fileIconClass: computed('file.category', function() {
    const klass = {
       'Figure': 'fa-file-image-o',
       'Text': 'fa-file-text-o',
       'Table': 'fa-file-o',
       'Data': 'fa-file-o'
    };
    return klass[this.get('file.category')] || 'fa-file-o';
  }),

  attachmentUrl: computed('file.id', 'figure', function() {
    return ('/api/supporting_information_files/' +
            this.get('file.id') +
            '/update_attachment');
  }),

  actions: {
    enterDeleteState() {
      this.set('uiState', 'delete');
    },

    deleteFile() {
      this.attrs.deleteFile(this.get('file'));
      this.set('uiState', 'view');
    },

    cancelDelete() {
      this.set('uiState', 'view');
    },

    enterEditState() {
      this.set('uiState', 'edit');
    },

    validateTitle() {
      this.get('model').validateKey('title');
    },

    validateCategory() {
      this.get('model').validateKey('category');
    },

    cancelEdit(){
      this.get('file').rollback();
      this.get('model').validateAllKeys();
      if(this.get('model').validationErrorsPresent()) { return; }

      this.set('uiState', 'view');
    },

    saveEdit(){
      this.get('model').validateAllKeys();
      if(this.get('model').validationErrorsPresent()) { return; }

      this.attrs.updateFile(this.get('file'));
      this.set('uiState', 'view');
    }
  }
});
