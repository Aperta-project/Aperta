import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const { computed } = Ember;

export default TaskComponent.extend(ValidationErrorsMixin, {
  restless: Ember.inject.service('restless'),
  paperState: computed.alias('task.paper.publishingState'),
  nonPublishable: computed.not('publishable'),
  revisionNumberDesc: ['revisionNumber:desc'],
  decisions: computed.sort('task.paper.decisions', 'revisionNumberDesc'),
  latestDecision: computed.alias('decisions.firstObject'),
  previousDecisions: computed('decisions.[]', function() {
    return this.get('decisions').slice(1);
  }),

  finalDecision: computed('latestDecision.verdict', function() {
    return this.get('latestDecision.verdict') === 'accept' ||
      this.get('latestDecision.verdict') === 'reject';
  }),

  publishable: computed('paperState', 'task.completed', function() {
    return this.get('paperState') === 'submitted' &&
      this.get('task.completed') === false;
  }),

  actions: {
    registerDecision() {
      const id = this.get('task.id');
      this.set('isSavingData', true);
      const decidePath = `/api/register_decision/${id}/decide`;

      this.get('restless').post(decidePath).then(() => {
        this.set('task.completed', true);
        this.get('task').save().then(() => {
          return this.get('latestDecision').save().then(() => {
            this.set('isSavingData', false);
          });
        });
      }, (response) => {
        this.set('isSavingData', false);
        this.displayValidationErrorsFromResponse(response.responseJSON);
      });
    },

    saveLatestDecision() {
      this.set('isSavingData', true);
      this.get('latestDecision').save().then(() => {
        this.set('isSavingData', false);
      });
    },

    setDecisionTemplate(decision) {
      const letter = this.get(`task.${decision.camelize()}LetterTemplate`);
      this.get('latestDecision').set('verdict', decision);
      this.get('latestDecision').set('letter', letter);
      this.send('saveLatestDecision');
    }
  }
});
