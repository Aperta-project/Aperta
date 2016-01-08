import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  restless: Ember.inject.service('restless'),

  letterBody: Ember.computed('task.body', function() {
    return this.get('task.body')[0];
  }),

  emptyLetterBody: Ember.computed('letterBody', function() {
    return Ember.isEmpty(this.get('letterBody'));
  }),

  actions: {
    saveCoverLetter() {
      this.set('task.body', [this.get('letterBody')]);
      this.get('task').save();
    },

    uploadFinished(s3Url, file) {
      const store = this.container.lookup('store:main');
      const path = `/api/tasks/${this.get('task.id')}/attachments`;
      this.get('restless').post(path, {url: s3Url}).then((response) => {
        response.attachment.filename = file.name
        store.pushPayload(response);
      });
    },

    deleteAttachment(attachment){
      attachment.destroyRecord();
    },

    noteChanged(note){
      console.log(note);
    }
  }
});
