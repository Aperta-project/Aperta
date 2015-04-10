import TaskController from 'tahi/pods/task/controller';
import FileUploadMixin from 'tahi/mixins/file-upload';

export default TaskController.extend(FileUploadMixin, {
  uploadUrl: function() {
    return '/supporting_information_files?paper_id=' + this.get('litePaper.id');
  }.property('litePaper.id'),

  actions: {
    uploadFinished: function(data, filename) {
      this.uploadFinished(data, filename);
      this.store.pushPayload('supportingInformationFile', data);
      // TODO: Do we need these anymore? Ember-Data should handle relationships now
      var file = this.store.getById('supportingInformationFile', data.supporting_information_file.id);
      this.get('paper.supportingInformationFiles').pushObject(file);
    },

    destroyAttachment: function(attachment) {
      attachment.destroyRecord();
    }
  }
});
