import Ember from 'ember';

export default Ember.Controller.extend({
  flash: Ember.inject.service(),
  restless: Ember.inject.service(),
  paperSubmitted: false,
  previousPublishingState: null,
  isFirstFullSubmission: Ember.computed.equal(
    'previousPublishingState', 'invited_for_full_submission'
  ),

  paper: Ember.computed.alias('model'),

  pdfDownloadLink: Ember.computed('paperid', function() {
    return '/papers/' + this.get('paper.id') + '/download.pdf';
  }),

  versions: Ember.computed('versions.[]', function() {
    const versions = this.get('paper.versionedTexts');
    this.set('versions', versions);
    return versions;
  }),

  recordPreviousPublishingState: function () {
    this.set('previousPublishingState', this.get('model.publishingState'));
  },

  actions: {
    submit() {
      this.recordPreviousPublishingState();
      this.get('restless').putUpdate(this.get('model'), '/submit').then(() => {
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
