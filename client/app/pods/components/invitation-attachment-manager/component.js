import Ember from 'ember';
import { task as concurrencyTask, timeout } from 'ember-concurrency';

export default Ember.Component.extend({
  multiple: false,
  invitation: null,

  enableEditingAttachments: true,

  enabled: Ember.computed.and('enableEditingAttachments', 'invitation.pending'),

  store: Ember.inject.service(),
  restless: Ember.inject.service(),

  attachmentsPath: Ember.computed('invitation.id', function() {
    return `/api/invitations/${this.get('invitation.id')}/attachments`;
  }),

  attachmentsRequest(path, method, s3Url, file) {
    const store = this.get('store');
    const restless = this.get('restless');
    restless.ajaxPromise(method, path, {url: s3Url}).then((response) => {
      response.attachment.filename = file.name;
      store.pushPayload(response);
    });
  },

  cancelUpload: concurrencyTask(function * (attachment) {
    yield attachment.cancelUpload();
    yield timeout(5000);
    attachment.unloadRecord();
  }),

  actions: {

    cancelUpload(attachment) {
      this.get('cancelUpload').perform(attachment);
    },

    updateAttachmentCaption(caption, attachment) {
      attachment.set('caption', caption);
      attachment.save();
    },

    updateAttachment(s3Url, file, attachment) {
      const path = `${this.get('attachmentsPath')}/${attachment.id}/update_attachment`;
      this.attachmentsRequest(path, 'PUT', s3Url, file);
    },

    createAttachment(s3Url, file) {
      this.attachmentsRequest(this.get('attachmentsPath'), 'POST', s3Url, file);
    },

    deleteAttachment(attachment) {
      attachment.destroyRecord();
    }
  }
});
