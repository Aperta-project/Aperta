import TaskComponent from 'tahi/pods/components/task-base/component';
import FileUploadMixin from 'tahi/mixins/file-upload';
import Ember from 'ember';

const { computed } = Ember;

export default TaskComponent.extend(FileUploadMixin, {
  classNames: ['supporting-information-task'],
  files: computed.alias('task.paper.supportingInformationFiles'),
  uploadUrl: computed('task', function() {
    return `/api/supporting_information_files?task_id=${this.get('task.id')}`;
  }),

  filesWithErrors: computed('files.[]', 'validationErrors', function() {
    return this.createModelProxyObjectWithErrors(this.get('files'));
  }),

  actions: {
    uploadFinished(data, filename) {
      this.uploadFinished(data, filename);
      this.store.pushPayload('supportingInformationFile', data);

      // TODO: Do we need these anymore?
      // Ember-Data should handle relationships now
      const file = this.store.getById(
        'supportingInformationFile',
        data.supporting_information_file.id
      );

      this.get('files').pushObject(file);
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
