import Ember from 'ember';
import { task as concurrencyTask, timeout } from 'ember-concurrency';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  restless: Ember.inject.service(),
  editing: false,
  bodyPart: null,
  bodyPartType: Ember.computed.alias('bodyPart.type'),
  hasAttachments: Ember.computed.notEmpty('task.attachments'),
  showAttachments: false,
  showAttachmentsBlock: Ember.computed.or('hasAttachments', 'showAttachments'),

  attachmentsRequest: Ember.concurrencyTask(function * (path, method, s3Url, file) {
    const store = this.get('store');
    const restless = this.get('restless');
    let response = yield restless.ajaxPromise(method, path, {url: s3Url});
    response.attachment.filename = file.name;
    store.pushPayload(response);
  }),

  attachmentsPath: Ember.computed('task.id', function() {
    return `/api/tasks/${this.get('task.id')}/attachments`;
  }),

  cancelUpload: concurrencyTask(function * (attachment) {
    yield attachment.cancelUpload();
    yield timeout(5000);
    attachment.unloadRecord();
  }),
  actions: {
    updateAttachmentCaption(caption, attachment) {
      attachment.set('caption', caption);
      attachment.save();
    },

    updateAttachment(s3Url, file, attachment) {
      const path = `${this.get('attachmentsPath')}/${attachment.id}/update_attachment`;
      this.get('attachmentsRequest').perform(path, 'PUT', s3Url, file);
    },

    createAttachment(s3Url, file) {
      this.get('attachmentsRequest').perform(this.get('attachmentsPath'), 'POST', s3Url, file);
    },

    deleteAttachment(attachment) {
      attachment.destroyRecord();
    },

    cancelUpload(attachment) {
      this.get('cancelUpload').perform(attachment);
    },

    uploadFailed(reason) {
      throw new Ember.Error(`Upload from browser to s3 failed: ${reason}`);
    },

    addAttachmentsBlock() {
      this.set('showAttachments', true);
    }
  }
});
