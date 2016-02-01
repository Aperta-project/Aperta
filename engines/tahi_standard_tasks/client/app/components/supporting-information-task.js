import TaskComponent from 'tahi/pods/components/task-base/component';
import FileUploadMixin from 'tahi/mixins/file-upload';
import Ember from 'ember';

export default TaskComponent.extend(FileUploadMixin, {
  classNames: ['supporting-information-task'],
  files: Ember.computed.alias('task.paper.supportingInformationFiles'),
  uploadUrl: Ember.computed('task', function() {
    return `/api/supporting_information_files?task_id=${this.get('task.id')}`;
  }),

  filesWithErrors: Ember.computed('files.[]', 'validationErrors', function() {
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

    destroyAttachment(attachment) {
      attachment.destroyRecord();
    }
  }
});
