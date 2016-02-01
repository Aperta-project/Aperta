import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
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

  validations: {
    'title': ['presence'],
    'category': ['presence']
  },

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

    delete() {
      this.get('file').destroyRecord();
      this.set('uiState', 'view');
    },

    cancelDelete() {
      this.set('uiState', 'view');
    },

    enterEditState() {
      this.set('uiState', 'edit');
    },

    cancelEdit(){
      this.get('file').rollback();
      this.set('uiState', 'view');
    },

    validateTitle() {
      this.validate('title', this.get('file.title'),
                           this.get('validations.title'));
    },

    saveEdit(){
      this.validateFields();
      if(this.validationErrorsPresent()) return;
      this.get('file').save();
      this.set('uiState', 'view');
    }
  }
});
