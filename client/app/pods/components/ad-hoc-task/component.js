import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import BuildsTaskTemplate from 'tahi/mixins/controllers/builds-task-template';
import FileUploadMixin from 'tahi/mixins/file-upload';

export default TaskComponent.extend(BuildsTaskTemplate, FileUploadMixin, {
  restless: Ember.inject.service('restless'),
  blocks: Ember.computed.alias('task.body'),

  imageUploadUrl: Ember.computed('task.id', function() {
    return '/api/tasks/' + this.get('task.id') + '/attachments';
  }),

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

    destroyAttachment(attachment) {
      attachment.destroyRecord();
    },

    uploadFinished(data, filename) {
      const store = this.container.lookup('store:main');

      this.uploadFinished(data, filename);
      store.pushPayload('attachment', data);

      const attachment = store.getById('attachment', data.attachment.id);
      this.get('task.attachments').pushObject(attachment);
    }
  }
});
