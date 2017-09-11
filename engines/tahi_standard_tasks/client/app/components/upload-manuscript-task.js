import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  validateData() {
    this.validateAll();
    const taskErrors = this.validationErrorsPresent();

    if (taskErrors) {
      this.set('validationErrors.completed', 'Please correct the errors below');
    }
  },
  needsSourcefile: Ember.computed(
    'pdfAllowed',
    'task.paper.file.computedFileType',
    function() {
      return (
        this.get('pdfAllowed') && this.get('task.paper.file.computedFileType') === 'pdf'
      );
    }
  )
});
