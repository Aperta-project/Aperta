import Ember from 'ember';

export default Ember.Component.extend({
  multiple: false,
  invitation: null,
  classNames: ['invitation-attachment-manager'],

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

  actions: {
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
    }
  }
});
