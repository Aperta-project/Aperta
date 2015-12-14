import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

const { computed } = Ember;
const {
  alias,
  and,
  empty,
  equal,
  none,
  not,
  or
} = computed;

export default TaskComponent.extend({
  restless: Ember.inject.service(),
  initialDecision: alias('task.paper.decisions.firstObject'),
  isSavingData: alias('initialDecision.isSaving'),
  paper: alias('task.paper'),
  isTaskCompleted: equal('task.completed', true),
  isTaskUncompleted: not('isTaskCompleted'),
  publishable: and('isPaperInitiallySubmitted', 'isTaskUncompleted'),
  nonPublishable: not('publishable'),
  hasNoLetter: empty('initialDecision.letter'),
  hasNoVerdict: none('initialDecision.verdict'),
  isPaperInitiallySubmitted: equal('paper.publishingState',
                                   'initially_submitted'),

  cannotRegisterDecision: or('hasNoLetter',
                             'hasNoVerdict',
                             'isTaskCompleted'),

  verdict: computed('initialDecision.verdict', function() {
    if (this.get('initialDecision.verdict')) {
      return this.get('initialDecision.verdict').replace(/_/g, ' ');
    }
  }),

  actions: {
    registerDecision() {
      const path = '/api/initial_decision/' + this.get('task.id');

      this.get('initialDecision').save().then(() => {
        return this.get('restless').post(path);
      }).then(() => {
        this.set('task.completed', true);
        this.get('task').save();
      });
    },

    setInitialDecisionVerdict(decision) {
      this.get('initialDecision').set('verdict', decision);
    }
  }
});
