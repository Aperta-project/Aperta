import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import { task as concurrencyTask, timeout } from 'ember-concurrency';

const {
  computed,
  inject: {service},
  isEmpty
} = Ember;

export default TaskComponent.extend({
  restless: service(),
  store: service(),

  validateData() {
    this.validateAll();
  },

  latestRegisteredDecision: computed.alias('task.paper.latestRegisteredDecision'),

  validations: {
    'response': [{
      type: 'presence',
      message: 'Please provide a response or attach a file',
      validation() {
        return !isEmpty(this.get('task.attachments')) || !isEmpty(this.get('latestRegisteredDecision.authorResponse'));
      }
    }]
  },

  cancelUpload: concurrencyTask(function * (attachment) {
    yield attachment.cancelUpload();
    yield timeout(5000);
    attachment.unloadRecord();
  }),

  canUploadAttachments: computed('editingAuthorResponse', 'isEditable', function () {
    return this.get('editingAuthorResponse') && this.get('isEditable');
  }),

  previousDecisions: computed.alias('task.paper.previousDecisions'),

  editingAuthorResponse: false,

  init() {
    this._super(...arguments);
    this.set(
      'editingAuthorResponse',
      isEmpty(this.get('latestRegisteredDecision.authorResponse')) || isEmpty(this.get('task.attachments'))
    );
  },

  attachmentsPath: computed('task.id', function() {
    return `/api/tasks/${this.get('task.id')}/attachments`;
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
    cancelUpload(attachment) {
      this.get('cancelUpload').perform(attachment);
    },

    saveAuthorResponse() {
      this.validateData();
      if(this.validationErrorsPresent()) { return; }

      this.get('latestRegisteredDecision').save().then(()=> {
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
