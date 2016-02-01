import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import BuildsTaskTemplate from 'tahi/mixins/controllers/builds-task-template';

export default TaskComponent.extend(BuildsTaskTemplate, {
  restless: Ember.inject.service(),
  blocks: Ember.computed.alias('task.body'),

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

    uploadFinished(s3Url){
      const store = this.container.lookup('store:main');
      const path = `/api/tasks/${this.get('task.id')}/attachments`;
      this.get('restless').post(path, {url: s3Url}).then((response) => {
        store.pushPayload(response);
      });
    },

    uploadFailed(reason) {
      console.log(reason);
    },
  }
});
