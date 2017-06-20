import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default TaskComponent.extend(ValidationErrorsMixin, {
  paperNotEditable: Ember.computed.not('task.paper.editable'),
  isNotEditable: Ember.computed.alias('task.completed'),

  validations: {
    'paperTitle': ['presence'],
    'paperAbstract': ['presence']
  },

  actions: {
    focusOut() {
      this.validateAll();

      if(!this.validationErrorsPresent()) {
        return this.get('task').save();
      }
    }
  }
});
