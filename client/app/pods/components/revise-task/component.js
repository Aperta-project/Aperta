import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

const {
  computed,
  inject: {service},
  isEmpty
} = Ember;

export default TaskComponent.extend({
  classNames: ['revise-manuscript-task'],
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
        return !isEmpty(this.get('latestRegisteredDecision.attachments')) || !isEmpty(this.get('latestRegisteredDecision.authorResponse'));
      }
    }]
  },

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
    // Each time the Response to Reviewers card is opened, refresh the decision
    // history. Unfortunately, slanger will not update the RtR card while it is
    // already open since decisions is a hasMany relationships, and the
    // notification from Pusher is for a single decision.
    if (this.get('task.paper.decisions'))
      this.get('task.paper.decisions').reload();
  },

  attachmentsPath: computed('latestRegisteredDecision.id', function() {
    return `/api/decisions/${this.get('latestRegisteredDecision.id')}/attachments`;
  }),

  attachmentsRequest(path, method, s3Url, file) {
    const store = this.get('store');
    const restless = this.get('restless');
    restless.ajaxPromise(method, path, {url: s3Url}).then((response) => {
      // The controller responds with a json that has decision-attachment or
      // attachment as the root, depending on the action called.
      if (response['decision-attachment'])
        response['decision-attachment'].title = file.name;
      else
        response['attachment'].title = file;
      store.pushPayload(response);
    });
  },

  actions: {
    saveAuthorContent(contents) {
      this.set('latestRegisteredDecision.authorResponse', contents);
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

    cancelUpload(attachment) {
      this.get('cancelUpload').perform(attachment);
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
