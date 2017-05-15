import Ember from 'ember';

const {
  Component,
  computed,
  computed: { alias, equal }
} = Ember;

export default Component.extend({
  classNames: ['si-file'],
  classNameBindings: ['uiStateClass'],
  file: alias('model.object'),
  isEditable: false, // passed-in
  uiState: 'view', // view, edit, delete
  errorsPresent: alias('model.errorsPresent'),
  isFileError: equal('file.status', 'error'),
  isEditing: equal('uiState', 'edit'),
  legendsAllowed: alias('file.paper.legendsAllowed'),

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

  uploadErrorMessage: Ember.computed('file.filename', function() {
    const filename = this.get('file.filename') || 'your file';
    return `There was an error while processing ${filename}. Please try again
    or contact Aperta staff.`;
  }),

  actions: {
    enterDeleteState() {
      this.set('uiState', 'delete');
    },

    deleteFile() {
      this.get('deleteFile')(this.get('file'));
      this.setProperties({
        uiState: 'view',
        deleting: true
      });
    },

    cancelDelete() {
      this.set('uiState', 'view');
    },

    enterEditStateIfEditable() {
      if(this.get('isEditable')) {
        this.set('uiState', 'edit');
      }
    },

    validateCategory() {
      this.get('model').validateProperty('category');
    },

    validateLabel() {
      this.get('model').validateProperty('label');
    },

    cancelEdit(){
      this.get('file').rollbackAttributes();
      this.set('uiState', 'view');
    },

    saveEdit(){
      this.get('model').validateAll();
      if(this.get('model').validationErrorsPresent()) { return; }

      this.get('updateFile')(this.get('file'));
      this.set('uiState', 'view');
    },

    uploadFinished() {
      this.get('model').validateAll();
    },
  }
});
