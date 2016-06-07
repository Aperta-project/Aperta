import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';

const {
  computed,
  inject: {service},
  isEmpty,
  on
} = Ember;

export default TaskComponent.extend({
  restless: service(),

  validateData() {
    this.validateAll();
  },

  validations: {
    'response': [{
      type: 'presence',
      message: 'Please provide a response or attach a file',
      validation() {
        return !isEmpty(this.get('task.attachments')) || !isEmpty(this.get('latestDecision.authorResponse'));
      }
    }]
  },

  canUploadAttachments: computed('editingAuthorResponse', 'isEditable', function () {
    return this.get('editingAuthorResponse') && this.get('isEditable');
  }),

  latestDecision: computed.alias('task.paper.latestRegisteredDecision'),

  previousDecisions: computed.alias('task.paper.previousDecisions'),

  editingAuthorResponse: false,

  _editIfResponseIsEmpty: on('didInsertElement', function() {
    this.set(
      'editingAuthorResponse',
      isEmpty(this.get('latestDecision.authorResponse')) || isEmpty(this.get('task.attachments'))
    );
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
      this.validateData();
      if(this.validationErrorsPresent()) { return; }

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
