import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import BuildsTaskTemplate from 'tahi/mixins/controllers/builds-task-template';

export default TaskComponent.extend(BuildsTaskTemplate, {
  restless: Ember.inject.service(),
  blocks: Ember.computed.alias('task.body'),
  hasAttachments: Ember.computed.notEmpty('task.attachments'),
  showAttachments: false,
  showAttachmentsBlock: Ember.computed.or('hasAttachments', 'showAttachments'),

  attachmentsPath: Ember.computed('task.id', function() {
    return `/api/tasks/${this.get('task.id')}/attachments`;
  }),

  attachmentsRequest(path, method, s3Url, file) {
    const store = this.container.lookup('store:main');
    const restless = this.get('restless');
    restless.ajaxPromise(method, path, {url: s3Url}).then((response) => {
      response.attachment.filename = file.name;
      store.pushPayload(response);
    });
  },

  actions: {
    setTitle(title) {
      this._super(title);
      this.send('save');
    },

    saveBlock(block) {
      this._super(block);
      this.send('save');
    },

    deleteBlock(block) {
      this._super(block);
      if (!this.isNew(block)) {
        this.send('save');
      }
    },

    deleteItem(item, block) {
      this._super(item, block);
      if (!this.isNew(block)) {
        this.send('save');
      }
    },

    sendEmail(data) {
      this.get('restless').putModel(this.get('task'), '/send_message', {
        task: data
      });

      this.send('save');
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
    },

    uploadFailed(reason) {
      console.log(reason);
    },

    addAttachmentsBlock() {
      this.set('showAttachments', true);
    }
  }
});
