import AttachmentAdapter from 'tahi/adapters/attachment';

export default AttachmentAdapter.extend({
  pathForType() { return 'manuscript_attachments'; },
  urlForCreateRecord(modelName, snapshot) {
    return `/api/tasks/${snapshot.record.get('task.id')}/upload_manuscript`;
  },

  urlForUpdateRecord(id, modelName, snapshot) {
    return `/api/tasks/${snapshot.record.get('task.id')}/upload_manuscript`;
  },

  urlForDeleteRecord(id, modelName, snapshot) {
    return `/api/tasks/${snapshot.record.get('task.id')}/delete_manuscript`;
  }
});
