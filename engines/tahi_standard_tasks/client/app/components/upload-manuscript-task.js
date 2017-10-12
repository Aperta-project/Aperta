import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import { CardEventListener } from 'tahi/pods/card-event/service';

export default TaskComponent.extend(CardEventListener, {
  cardEvents: {
    onPaperFileUploaded: 'clearSourcefileErrors'
  },

  validateData() {
    this.validateAll();
    const taskErrors = this.validationErrorsPresent();

    if (taskErrors) {
      this.set('validationErrors.completed', 'Please correct the errors below');
    }
  },

  clearSourcefileErrors(filetype) {
    if (filetype === 'sourcefile' || filetype === 'manuscript') {
      this.set('validationErrors', {});
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
