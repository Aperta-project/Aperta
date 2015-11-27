import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

export default TaskController.extend({
  restless: Ember.inject.service('restless'),
  paperState: Ember.computed.alias('model.paper.publishingState'),
  nonPublishable: Ember.computed.not('publishable'),
  decisions: Ember.computed.alias('model.paper.decisions'),
  latestDecision: Ember.computed.alias('decisions.firstObject'),
  previousDecisions: Ember.computed('decisions.[]', function() {
    return this.get('decisions').slice(1);
  }),

  finalDecision: Ember.computed('latestDecision.verdict', function() {
    return this.get('latestDecision.verdict') === 'accept' ||
      this.get('latestDecision.verdict') === 'reject';
  }),

  publishable: Ember.computed('paperState', 'model.completed', function() {
    return this.get('paperState') === 'submitted' &&
      this.get('model.completed') === false;
  }),

  actions: {
    registerDecision() {
      this.set('isSavingData', true);
      let decidePath = `/api/register_decision/${this.get('model.id')}/decide`;
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
