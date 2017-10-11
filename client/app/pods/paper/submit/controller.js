import Ember from 'ember';
import { paperDownloadPath } from 'tahi/utils/api-path-helpers';

export default Ember.Controller.extend({
  flash: Ember.inject.service(),
  restless: Ember.inject.service(),
  showFeedbackOverlay: false,
  paperSubmitted: false,
  previousPublishingState: null,
  isFirstFullSubmission: Ember.computed.equal(
    'previousPublishingState', 'invited_for_full_submission'
  ),

  paper: Ember.computed.alias('model.paper'),
  tasks: Ember.computed.alias('model.tasks'),

  preprintOptOut: Ember.computed('paper.preprintOptOut', function() {
    return this.get('paper.preprintOptOut');
  }),

  fileDownloadUrl: Ember.computed('paper', function() {
    return paperDownloadPath({ paperId: this.get('paper.id'), format: 'pdf_with_attachments' });
  }),

  recordPreviousPublishingState: function () {
    this.set('previousPublishingState', this.get('paper.publishingState'));
  },

  showFeedbackOverlayFunc() {
    this.set('showFeedbackOverlay', true);
  },

  setPaperStateAsSubmitted() {
    this.set('paperSubmitted', true);
  },

  actions: {
    submit() {
      this.recordPreviousPublishingState();
      this.get('restless').putUpdate(this.get('paper'), '/submit').then(() => {
        this.setPaperStateAsSubmitted();
        this.showFeedbackOverlayFunc();
      }, (arg) => {
        const status = arg.status;
        const model = arg.model;
        let message;
        const errors = model ? model.get('errors.messages') : arg.errors;
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
    },

    hideFeedbackOverlay() {
      this.set('showFeedbackOverlay', false);
      this.transitionToRoute('paper.index', this.get('paper.shortDoi'));
    },

    close() {
      this.attrs.close();
    }
  }
});
