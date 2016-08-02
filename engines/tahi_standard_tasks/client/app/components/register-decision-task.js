import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const { computed } = Ember;

export default TaskComponent.extend(ValidationErrorsMixin, {
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

      this.set('isSavingData', true);

      this.get('latestDecision').register(task)
        .then(() => {
          this.set('decidedDecision', this.get('latestDecision.verdict'));
          this.set('task.completed', true);
          this.get('task').save().then(() => {
            return this.get('latestDecision').save().then(() => {
              const tasksPromise = this.get('task.paper.tasks').reload();
              const decisionsPromise = this.get('task.paper.decisions').reload();
              return Ember.RSVP.all([tasksPromise, decisionsPromise]).then(() => {
                this.set('isSavingData', false);
                this.clearAllValidationErrors();
              });
            });
          })
          .catch((response) => {
            this.displayValidationErrorsFromResponse(response.responseJSON);
          })
          .finally(() => {
            this.set('isSavingData', false);
          });
        });
    },

    showSpinner() {
      this.set('isSavingData', true);
    },

    hideSpinner() {
      this.set('isSavingData', false);
    },

    templateSelected(template) {
      const letter = this.applyTemplateReplacements(template.letter);
      const to = this.applyTemplateReplacements(template.to);
      const subject = this.applyTemplateReplacements(template.subject);
      this.set('toField', to);
      this.set('subjectLine', subject);
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
