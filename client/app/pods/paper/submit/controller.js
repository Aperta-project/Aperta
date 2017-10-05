import Ember from 'ember';
import { paperDownloadPath } from 'tahi/utils/api-path-helpers';

export default Ember.Controller.extend({
  flash: Ember.inject.service(),
  restless: Ember.inject.service(),
  paperSubmitted: false,
  previousPublishingState: null,
  isFirstFullSubmission: Ember.computed.equal(
    'previousPublishingState', 'invited_for_full_submission'
  ),

  paper: Ember.computed.alias('model.paper'),
  tasks: Ember.computed.alias('model.tasks'),
  prePrintTask: Ember.computed.alias('model.prePrintTask'),

  prePrintOptOut: Ember.computed('paper.tasks.[]', function() {
    let prePrintTask = this.get('tasks').findBy('title', 'Preprint Posting');
    const answer = prePrintTask ? prePrintTask.get('answers.firstObject.value') : undefined;
    let value = (answer === '2');
    return value;
  }),

  fileDownloadUrl: Ember.computed('paper', function() {
    return paperDownloadPath({ paperId: this.get('paper.id'), format: 'pdf_with_attachments' });
  }),

  recordPreviousPublishingState: function () {
    this.set('previousPublishingState', this.get('paper.publishingState'));
  },

  actions: {
    submit() {
      this.recordPreviousPublishingState();
      this.get('restless').putUpdate(this.get('paper'), '/submit').then(() => {
        this.set('paperSubmitted', true);
      }, (arg) => {
        const status = arg.status;
        const model = arg.model;
        let message;
        const errors = model.get('errors.messages');
        switch (status) {
        case 422:
          message = errors + ' You should probably reload.';
          break;
        case 403:
          message = 'You weren\'t authorized to do that';
          break;
        default:
          message = 'There was a problem saving. Please reload.';
        }

        this.get('flash').displayRouteLevelMessage('error', message);
      });
    }
  }
});
