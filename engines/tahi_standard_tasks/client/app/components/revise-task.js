import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';

const {
  computed,
  inject: {service},
  on
} = Ember;

export default TaskComponent.extend({
  restless: service(),

  latestDecision: computed('previousDecisions', function() {
    return this.get('task.paper.decisions')
               .sortBy('revisionNumber').reverse()[1];
  }),

  previousDecisions: computed('task.paper.decisions.[]', function() {
    return this.get('task.paper.decisions')
               .sortBy('revisionNumber').reverse().slice(2);
  }),

  editingAuthorResponse: false,

  _editIfResponseIsEmpty: on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      this.set(
        'editingAuthorResponse',
        Ember.isEmpty(this.get('latestDecision.authorResponse'))
      );
    });
  }),

  attachmentsPath: computed('task.id', function() {
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
    saveAuthorResponse() {
      this.get('latestDecision').save().then(()=> {
        this.set('editingAuthorResponse', false);
      });
    },

    editAuthorResponse() {
      this.set('editingAuthorResponse', true);
    },

    deleteAttachment(attachment) {
      attachment.destroyRecord();
    },

    createAttachment(s3Url, file) {
      this.attachmentsRequest(this.get('attachmentsPath'), 'POST', s3Url, file);
    },

    updateAttachment(s3Url, file, attachment) {
      const path = `${this.get('attachmentsPath')}/${attachment.id}/update_attachment`;
      this.attachmentsRequest(path, 'PUT', s3Url, file);
    }
  }
});
