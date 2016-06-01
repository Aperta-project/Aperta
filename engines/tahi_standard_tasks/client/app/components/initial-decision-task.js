import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

const { computed } = Ember;
const {
  and,
  empty,
  equal,
  none,
  not,
  or
} = computed;

export default TaskComponent.extend({
  restless: Ember.inject.service(),
  isSavingData: false,
  isTaskCompleted: equal('task.completed', true),
  isTaskUncompleted: not('isTaskCompleted'),
  publishable: and('isPaperInitiallySubmitted', 'isTaskUncompleted'),
  initialDecisions: computed.filterBy('task.paper.decisions', 'initial', true),
  initialDecision: computed.alias('task.paper.initialDecision'),
  nonPublishable: not('publishable'),
  hasNoLetter: empty('initialDecision.letter'),
  hasNoVerdict: none('initialDecision.verdict'),
  isPaperInitiallySubmitted: equal('task.paper.publishingState',
                                   'initially_submitted'),

  cannotRegisterDecision: or('hasNoLetter',
                             'hasNoVerdict',
                             'isTaskCompleted'),

  initialDecision: computed('task.paper.decisions.[]', function() {
    return this.get('task.paper.decisions').findBy('revisionNumber', 0);
  }),

  actions: {
    registerDecision() {
      this.set('isSavingData', true);
      this.get('initialDecision').register(this.get('task'))
        .finally(() => {
          this.set('isSavingData', false);
      });
    },

    setInitialDecisionVerdict(decision) {
      this.get('initialDecision').set('verdict', decision);
    }
  }
});
