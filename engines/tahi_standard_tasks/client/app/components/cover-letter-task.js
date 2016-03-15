import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';

export default TaskComponent.extend({
  restless: Ember.inject.service('restless'),

  letterBody: Ember.computed('task.body', function() {
    return this.get('task.body')[0];
  }),

  emptyLetterBody: Ember.computed('letterBody', function() {
    return Ember.isEmpty(this.get('letterBody'));
  }),

  attachmentsPath: Ember.computed('task.id', function() {
    return `/api/tasks/${this.get('task.id')}/attachments`;
  }),

  attachmentsRequest(path, method, s3Url, file) {
    const store = getOwner(this).lookup('store:main');
    const restless = this.get('restless');
    restless.ajaxPromise(method, path, {url: s3Url}).then((response) => {
      response.attachment.filename = file.name;
      store.pushPayload(response);
    });
  },

  actions: {
    saveCoverLetter() {
      this.set('task.body', [this.get('letterBody')]);
      this.get('task').save();
    },

    updateAttachment(s3Url, file, attachment) {
      const path = `${this.get('attachmentsPath')}/${attachment.id}/update_attachment`;
      this.attachmentsRequest(path, 'PUT', s3Url, file);
    },

    createAttachment(s3Url, file) {
      this.attachmentsRequest(this.get('attachmentsPath'), 'POST', s3Url, file);
    },

    deleteAttachment(attachment){
      attachment.destroyRecord();
    }
  }
});
