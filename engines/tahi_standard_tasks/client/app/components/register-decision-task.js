import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import HasBusyStateMixin from 'tahi/mixins/has-busy-state';

const { computed } = Ember;

export default TaskComponent.extend(ValidationErrorsMixin, HasBusyStateMixin, {
  init: function(){
    this._super(...arguments);
    this.get('task.paper.decisions').reload();
  },
  decidedDecision: null,
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

  toField: null,
  subjectLine: null,
  latestDecision: computed.alias('paper.latestDecision'),
  latestRegisteredDecision: computed.alias('paper.latestRegisteredDecision'),
  previousDecisions: computed.alias('paper.previousDecisions'),
  isLoading: computed.oneWay('isBusy'),

  verdicts: ['reject', 'major_revision', 'minor_revision', 'accept'],

  applyTemplateReplacements(str) {
    str = str.replace(/\[YOUR NAME\]/g, this.get('currentUser.fullName'));
    str = str.replace(/\[AUTHOR EMAIL\]/g, this.get('task.paper.creator.email'));
    str = str.replace(/\[PAPER TITLE\]/g, this.get('task.paper.shortTitle'));
    str = str.replace(/\[JOURNAL NAME\]/g, this.get('task.paper.journal.name'));
    return str.replace(/\[LAST NAME\]/g, this.get('task.paper.creator.lastName'));
  },

  triggerSave: Ember.observer('latestDecision.letter', function() {
    let latestDecision = this.get('latestDecision');
    if (latestDecision) {
      Ember.run.debounce(latestDecision, latestDecision.save, 500);
    }
  }),

  actions: {
    registerDecision() {
      let task = this.get('task');

      this.set('decidedDecision', this.get('latestDecision.verdict'));

      this.busyWhile(
        this.get('latestDecision').register(task)
          .then(() => {
            // reload to pick up completed flag on current task and possibly new
            // Revise Manuscript task
            return this.get('task.paper.tasks').reload();
          }).then(() => {
            this.clearAllValidationErrors();
          }).catch((response) => {
            this.displayValidationErrorsFromResponse(response.responseJSON);
          })
      );
    },

    templateSelected(template) {
      const letter = this.applyTemplateReplacements(template.letter);
      const to = this.applyTemplateReplacements(template.to);
      const subject = this.applyTemplateReplacements(template.subject);
      const toQuestion = this.get('task').findQuestion('register_decision_questions--to-field');
      const toAnswer = toQuestion.answerForOwner(this.get('task'));
      const subjectQuestion = this.get('task').findQuestion('register_decision_questions--subject-field');
      const subjectAnswer = subjectQuestion.answerForOwner(this.get('task'));
      toAnswer.set('value', to);
      subjectAnswer.set('value', subject);
      this.get('latestDecision').set('verdict', template.templateDecision);
      this.get('latestDecision').set('letter', letter); // will trigger save
      return template;
    },

    setDecisionTemplate(decision) {
      const templates = this.get(`task.${decision.camelize()}LetterTemplates`);
      const template = templates.get('firstObject');
      this.send('templateSelected', template.toJSON());
    }
  }
});
