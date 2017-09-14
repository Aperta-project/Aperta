import AttachmentAdapter from 'tahi/adapters/attachment';

/**
 * Manuscript attachments and sourcefile attachments go to the same endpoint
 */
export default AttachmentAdapter.extend({
  pathForType() { return 'sourcefile_attachments'; },
  urlForCreateRecord(modelName, snapshot) {
    return `/api/tasks/${snapshot.record.get('task.id')}/upload_manuscript`;
  },

  urlForUpdateRecord(id, modelName, snapshot) {
    return `/api/tasks/${snapshot.record.get('task.id')}/upload_manuscript`;
  },

  // delete is different
  urlForDeleteRecord(id, modelName, snapshot) {
    return `/api/tasks/${snapshot.record.get('task.id')}/delete_sourcefile`;
  }
});
