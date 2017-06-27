import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

const taskValidations = {
  'paperTitle': ['presence'],
  'paperAbstract': ['presence']
};

export default TaskComponent.extend({
  paperNotEditable: Ember.computed.not('task.paper.editable'),
  isNotEditable: Ember.computed.alias('task.completed'),
  validations: taskValidations,

  validateData() {
    this.validateAll();
    const taskErrors = this.validationErrorsPresent();

    if(taskErrors) {
      this.set('validationErrors.completed', 'Please fix all errors');
    }
  },

  actions: {
    focusOut() {
      this.set('validationErrors.completed', '');
      this.validateAll();
      if(!this.validationErrorsPresent()) {
        return this.get('task').save();
      }
    }
  }
});
