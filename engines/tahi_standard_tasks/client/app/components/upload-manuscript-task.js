import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

const taskValidations = {
  hasSourceIfNeeded: [
    {
      type: 'equality',
      message: 'Please upload your source file',
      validation() {
        if (this.get('task.paper.file.fileType') !== 'pdf') return true;

        let versions = this.get('task.paper.versionedTexts');
        let inRevision =
          this.get('task.paper.publishingState') === 'in_revision';
        if (inRevision || versions.any(v => v.get('majorVersion') > 0)) {
          return this.get('task.paper.sourcefile');
        } else {
          return true;
        }
      }
    }
  ]
};

export default TaskComponent.extend({
  validations: taskValidations,

  validateData() {
    this.validateAll();
    const taskErrors = this.validationErrorsPresent();

    if (taskErrors) {
      this.set('validationErrors.completed', 'Please correct the errors below');
    }
  },
  pdfAllowed: Ember.computed.reads('task.paper.journal.pdfAllowed'),
  needsSourcefile: Ember.computed(
    'pdfAllowed',
    'task.paper.file.fileType',
    function() {
      return (
        this.get('pdfAllowed') && this.get('task.paper.file.fileType') === 'pdf'
      );
    }
  )
});
