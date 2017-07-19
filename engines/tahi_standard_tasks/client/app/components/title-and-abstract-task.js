import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

const taskValidations = {
  'paperTitle': ['presence'],
  'paperAbstract': ['presence']
};

export default TaskComponent.extend({
  paperNotEditable: Ember.computed.not('task.paper.editable'),
  isNotEditable: Ember.computed('task.completed', 'paperNotEditable', function () {
    return this.get('task.completed') || this.get('paperNotEditable');
  }),
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
