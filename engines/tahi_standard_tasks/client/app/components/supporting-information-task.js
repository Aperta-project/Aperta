import TaskComponent from 'tahi/pods/components/task-base/component';
import FileUploadMixin from 'tahi/mixins/file-upload';
import ObjectProxyWithErrors from 'tahi/models/object-proxy-with-validation-errors';
import Ember from 'ember';

const { computed } = Ember;

export default TaskComponent.extend(FileUploadMixin, {
  classNames: ['supporting-information-task'],
  files: computed.alias('task.paper.supportingInformationFiles'),
  uploadUrl: computed('task', function() {
    return `/api/supporting_information_files?task_id=${this.get('task.id')}`;
  }),

  validateData() {
    const objs = this.get('filesWithErrors');
    objs.invoke('validateAll');

    const errors = ObjectProxyWithErrors.errorsPresentInCollection(objs);

    if(errors) {
      this.set('validationErrors.completed', 'Please fix all errors');
    }
  },

  filesWithErrors: computed('files.[]', function() {
    return this.get('files').map(function(f) {
      return ObjectProxyWithErrors.create({
        object: f,
        validations: {
          'title': ['presence'],
          'category': ['presence']
        }
      });
    });
  }),

  actions: {
    uploadFinished(data, filename) {
      this.uploadFinished(data, filename);
      this.get('store').pushPayload('supporting-information-file', data);
    },

    deleteFile(file) {
      file.destroyRecord();
    },

    updateFile(file) {
      this.clearAllValidationErrorsForModel(file);
      file.save();
    }
  }
});
