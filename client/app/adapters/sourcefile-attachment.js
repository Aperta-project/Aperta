import AttachmentAdapter from 'tahi/adapters/attachment';

export default AttachmentAdapter.extend({
  pathForType() { return 'sourcefile_attachments'; },
  urlForCreateRecord(modelName, snapshot) {
    return `/api/tasks/${snapshot.record.get('task.id')}/upload_sourcefile`;
  },

  urlForUpdateRecord(id, modelName, snapshot) {
    return `/api/tasks/${snapshot.record.get('task.id')}/upload_sourcefile`;
  }
});
