import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

const { computed } = Ember;

export default TaskComponent.extend({
  restless: Ember.inject.service('restless'),
  paperState: computed.alias('model.paper.publishingState'),
  nonPublishable: computed.not('publishable'),
  revisionNumberDesc: ['revisionNumber:desc'],
  decisions: computed.sort('model.paper.decisions', 'revisionNumberDesc'),
  latestDecision: computed.alias('decisions.firstObject'),
  previousDecisions: computed('decisions.[]', function() {
    return this.get('decisions').slice(1);
  }),

  finalDecision: computed('latestDecision.verdict', function() {
    return this.get('latestDecision.verdict') === 'accept' ||
      this.get('latestDecision.verdict') === 'reject';
  }),

  publishable: computed('paperState', 'model.completed', function() {
    return this.get('paperState') === 'submitted' &&
      this.get('model.completed') === false;
  }),

  actions: {
    registerDecision() {
      const id = this.get('model.id');
      this.set('isSavingData', true);
      const decidePath = `/api/register_decision/${id}/decide`;

      this.get('restless').post(decidePath).then(() => {
        this.set('model.completed', true);
        this.get('model').save().then(() => {
          this.get('latestDecision').save().then(() => {
            this.set('isSavingData', false);
          });
        });
      });
    },

    saveLatestDecision() {
      this.set('isSavingData', true);
      this.get('latestDecision').save().then(() => {
        this.set('isSavingData', false);
      });
    },

    setDecisionTemplate(decision) {
      const letter = this.get(`model.${decision.camelize()}LetterTemplate`);
      this.get('latestDecision').set('verdict', decision);
      this.get('latestDecision').set('letter', letter);
      this.send('saveLatestDecision');
    }
  }
});
