import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';
import BuildsTaskTemplate from 'tahi/mixins/controllers/builds-task-template';
import FileUploadMixin from 'tahi/mixins/file-upload';
import RESTless from 'tahi/services/rest-less';

export default TaskController.extend(BuildsTaskTemplate, FileUploadMixin, {
  blocks: Ember.computed.alias('model.body'),

  imageUploadUrl: Ember.computed('model.id', function() {
    return '/api/tasks/' + (this.get('model.id')) + '/attachments';
  }),

  actions: {
    setTitle(title) {
      this._super(title);
      this.send('saveModel');
    },

    saveBlock(block) {
      this._super(block);
      this.send('saveModel');
    },

    deleteBlock(block) {
      this._super(block);
      if (!this.isNew(block)) {
        this.send('saveModel');
      }
    },

    deleteItem(item, block) {
      this._super(item, block);
      if (!this.isNew(block)) {
        this.send('saveModel');
      }
    },

    sendEmail(data) {
      RESTless.putModel(this.get('model'), '/send_message', {
        task: data
      });

      this.send('saveModel');
    },

    destroyAttachment(attachment) {
      attachment.destroyRecord();
    },

    uploadFinished(data, filename) {
      this.uploadFinished(data, filename);
      this.store.pushPayload('attachment', data);

      // TODO: ember-data handles relationships now
      let attachment = this.store.peekRecord('attachment', data.attachment.id);
      this.get('model.attachments').pushObject(attachment);
    }
  }
});
