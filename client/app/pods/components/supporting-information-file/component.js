import Ember from 'ember';

const {
  Component,
  computed,
  computed: { alias, equal }
} = Ember;

export default Component.extend({
  init() {
    this._super(...arguments);
    if(this.get('model.newlyUploaded')) {
      this.set('uiState', 'edit');
    }
  },

  classNames: ['si-file'],
  classNameBindings: ['uiStateClass'],
  file: alias('model.object'),
  isEditable: false, // passed-in
  uiState: 'view', // view, edit, delete
  errorsPresent: alias('model.errorsPresent'),
  isFileError: equal('file.status', 'error'),
  isEditing: equal('uiState', 'edit'),
  legendsAllowed: alias('file.paper.legendsAllowed'),
  content: Ember.Object.create(),
  answer: Ember.Object.create(),

  categories: [
    'Table',
    'Data',
    'Text',
    'Figure'
  ],

  hasSIErrors: computed('taskErrors.supportingInformationFiles', function( ){
    return !!this.get('taskErrors.supportingInformationFiles');
  }),

  hasSaveErrors: computed.or('hasSIErrors', 'model.validationErrors.save'),

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

  configEditor() {
    if (this.get('legendsAllowed')) {
      this.set('content.editorStyle', 'basic');
      this.set('content.valueType', 'html');
    }
  },

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
        this.configEditor();
      }
    },

    updateTitle(value) {
      if (!(typeof(value) === 'string')) { return; }
      this.set('file.title', value);
    },

    updateCaption(value) {
      if (!(typeof(value) === 'string')) { return; }
      this.set('file.caption', value);
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
    uploadFinished(){
      this.get('model').clearAllValidationErrors();
    }
  }
});
