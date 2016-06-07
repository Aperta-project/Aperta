import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const { computed } = Ember;

export default TaskComponent.extend(ValidationErrorsMixin, {
  restless: Ember.inject.service('restless'),
  paper: computed.alias('task.paper'),
  submitted: computed.equal('paper.publishingState', 'submitted'),
  uncompleted: computed.equal('task.completed', false),
  isNotEditable: false, // This task has custom editability behavior

  publishable: computed.and('submitted', 'uncompleted'),
  nonPublishable: computed.not('publishable'),
  nonPublishableOrUnselected: computed('latestDecision.verdict', 'task.completed', function() {
    return this.get('nonPublishable') || !this.get('latestDecision.verdict');
  }),

  latestDecision: computed.alias('paper.latestDecision'),
  latestRegisteredDecision: computed.alias('paper.latestRegisteredDecision'),
  previousDecisions: computed.alias('paper.previousDecisions'),

  finalDecision: computed('latestDecision.verdict', function() {
    return this.get('latestDecision.verdict') === 'accept' ||
      this.get('latestDecision.verdict') === 'reject';
  }),

  verdicts: ['reject', 'accept', 'major_revision', 'minor_revision'],

  applyTemplateReplacements(str) {
    return str.replace(/\[YOUR NAME\]/g, this.get('currentUser.fullName'));
  },

  actions: {
    registerDecision() {
      let task = this.get('task');

      this.set('isSavingData', true);

      this.get('latestDecision').register(task)
        .then(() => {
          this.clearAllValidationErrors();
        })
        .catch((response) => {
          this.displayValidationErrorsFromResponse(response.responseJSON);
        })
        .finally(() => {
          this.set('isSavingData', false);
        });
    },

    showSpinner() {
      this.set('isSavingData', true);
    },

    hideSpinner() {
      this.set('isSavingData', false);
    },

    saveLatestDecision() {
      this.set('isSavingData', true);
      this.get('latestDecision').save().then(() => {
        this.set('isSavingData', false);
      });
    },

    setDecisionTemplate(decision) {
      const template = this.get(`task.${decision.camelize()}LetterTemplate`);
      const letter = this.applyTemplateReplacements(template);
      this.get('latestDecision').set('verdict', decision);
      this.get('latestDecision').set('letter', letter);
      this.send('saveLatestDecision');
    }
  }
});
