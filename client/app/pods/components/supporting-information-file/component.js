import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNames: ['si-file'],
  classNameBindings: ['uiStateClass'],
  file: null, // passed-in
  isEditable: false, // passed-in
  uiState: 'view', // view, edit, delete

  validations: {
    'title': ['presence'],
    'category': ['presence']
  },

  isEditing: Ember.computed('validationErrors', 'uiState', function(){
    if (this.validationErrorsPresent()) {
      this.set('uiState', 'edit');
      return true;
    }
    if (this.get('uiState') === 'edit') return true;
    return false;
  }),

  categories: [
    'Table',
    'Data',
    'Text',
    'Figure'
  ],

  uiStateClass: Ember.computed('uiState', function() {
    return `si-file-${this.get('uiState')}`;
  }),

  fileIconClass: Ember.computed('file.category', function() {
    const klass = {
       'Figure': 'fa-file-image-o',
       'Text': 'fa-file-text-o',
       'Table': 'fa-file-o',
       'Data': 'fa-file-o'
    };
    return klass[this.get('file.category')] || 'fa-file-o';
  }),

  attachmentUrl: Ember.computed('file.id', 'figure', function() {
    return ('/api/supporting_information_files/' +
            this.get('file.id') +
            '/update_attachment');
  }),

  validateFields() {
    Ember.keys(this.get('validations')).forEach(field => {
      this.validate(field, this.get(`file.${field}`),
                           this.get(`validations.${field}`));
    });
  },

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
      this.validate('title', this.get('file.title'),
                             this.get('validations.title'));
    },

    cancelEdit(){
      this.get('file').rollback();
      this.set('uiState', 'view');
    },

    saveEdit(){
      this.validateFields();
      if(this.validationErrorsPresent()) return;
      this.attrs.updateFile(this.get('file'));
      this.set('uiState', 'view');
    }
  }
});
