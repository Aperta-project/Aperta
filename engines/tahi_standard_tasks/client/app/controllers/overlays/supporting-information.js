import TaskController from 'tahi/pods/task/controller';
import FileUploadMixin from 'tahi/mixins/file-upload';

export default TaskController.extend(FileUploadMixin, {
  uploadUrl: function() {
    return '/api/supporting_information_files?paper_id=' + this.get('model.paper.id');
  }.property('model.paper.id'),

  actions: {
    uploadFinished: function(data, filename) {
      this.uploadFinished(data, filename);
      this.store.pushPayload('supportingInformationFile', data);
    },

    destroyAttachment: function(attachment) {
      attachment.destroyRecord();
    }
  }
});
