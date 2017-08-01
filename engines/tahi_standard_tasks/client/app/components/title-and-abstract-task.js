import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

const taskValidations = {
  'paperTitle': ['presence'],
  'paperAbstract': ['presence']
};

export default TaskComponent.extend({
  validations: taskValidations,

  validateData() {
    this.validateAll();
    const taskErrors = this.validationErrorsPresent();
    this.validate('paperTitle', this.get('task.paperTitle'));
    this.validate('paperAbstract', this.get('task.paperAbstract'));
    if(taskErrors) {
      this.set('validationErrors.completed', 'Please fix all errors');
    }
  },
  paperTitleError: Ember.computed('validationErrors.paperTitle', function(){
    if (this.get('validationErrors.paperTitle')){
      return [this.get('validationErrors.paperTitle')];
    }
  }),
  paperAbstractError: Ember.computed('validationErrors.paperAbstract', function(){
    if (this.get('validationErrors.paperAbstract')){
      return [this.get('validationErrors.paperAbstract')];
    }
  }),
  actions: {
    titleChanged(contents) {
      this.set('task.paperTitle', contents);
      this.get('task.debouncedSave').perform();
    },

    abstractChanged(contents) {
      this.set('task.paperAbstract', contents);
    },

    focusOut() {
      this.set('validationErrors.completed', '');
      this.validateData();
      if(!this.validationErrorsPresent()) {
        return this.get('task').save();
      }
    }
  }
});
