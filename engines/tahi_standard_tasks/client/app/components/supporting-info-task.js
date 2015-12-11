import TaskComponent from 'tahi/pods/components/task-base/component';
import FileUploadMixin from 'tahi/mixins/file-upload';
import Ember from 'ember';

export default TaskComponent.extend(FileUploadMixin, {
  uploadUrl: Ember.computed('task.paper.id', function() {
    const id = this.get('task.paper.id');
    return '/api/supporting_information_files?paper_id=' + id;
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

      this.get('task.paper.supportingInformationFiles').pushObject(file);
    },

    destroyAttachment(attachment) {
      attachment.destroyRecord();
    }
  }
});
