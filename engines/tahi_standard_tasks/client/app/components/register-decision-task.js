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
  formattedDecidedDecision: computed('decidedDecision', function() {
    let words = this.get('decidedDecision').split(/_/g);
    return words.map(function(word) {
      return (word.charAt(0).toUpperCase() + word.slice(1));
    }).join(' ');
  }),
  restless: Ember.inject.service('restless'),
  paperState: computed.alias('task.paper.publishingState'),
  submitted: computed.equal('paperState', 'submitted'), 
  uncompleted: computed.equal('task.completed', false),
  isNotEditable: false, // This task has custom editability behavior
  nonPublishable: computed.not('publishable'),
  nonPublishableOrUnselected: computed('latestDecision.verdict', 'task.completed', function() {
    return this.get('nonPublishable') || !this.get('latestDecision.verdict');
  }),
  subjectLine: null,
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

  publishable: computed.and('submitted', 'uncompleted'),

  applyTemplateReplacements(str) {
    str = str.replace(/\[YOUR NAME\]/g, this.get('currentUser.fullName'));
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
      const id = this.get('task.id');
      this.set('isSavingData', true);
      const decidePath = `/api/register_decision/${id}/decide`;

      this.get('restless').post(decidePath).then(() => {
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
        });
      }, (response) => {
        this.set('isSavingData', false);
        this.displayValidationErrorsFromResponse(response.responseJSON);
      });
    },

    templateSelected(template) {
      const letter = this.applyTemplateReplacements(template.letter);
      const subject = this.applyTemplateReplacements(template.subject);
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
