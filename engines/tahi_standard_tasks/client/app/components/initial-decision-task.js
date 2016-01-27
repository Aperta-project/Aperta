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
      this.get('initialDecision').save().then(() => {
        const path = `/api/initial_decision/${this.get('task.id')}`;
        return this.get('restless').post(path);
      }).then(() => {
        this.set('task.completed', true);
        return this.get('task').save();
      }).then(() => {
        this.set('isSavingData', false);
      });
    },

    setInitialDecisionVerdict(decision) {
      this.get('initialDecision').set('verdict', decision);
    }
  }
});
