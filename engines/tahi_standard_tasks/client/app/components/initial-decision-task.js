import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import HasBusyStateMixin from 'tahi/mixins/has-busy-state';

const { computed } = Ember;
const {
  and,
  empty,
  equal,
  none,
  not,
  or
} = computed;

export default TaskComponent.extend(HasBusyStateMixin, {
  restless: Ember.inject.service(),
  busy: false,
  isTaskCompleted: equal('task.completed', true),
  isTaskUncompleted: not('isTaskCompleted'),
  publishable: and('isPaperInitiallySubmitted', 'isTaskUncompleted'),
  initialDecisions: computed.filterBy(
    'task.paper.sortedDecisions', 'initial', true),
  initialDecision: computed.alias('task.paper.initialDecision'),
  nonPublishable: not('publishable'),
  hasNoLetter: empty('initialDecision.letter'),
  hasNoVerdict: none('initialDecision.verdict'),
  isPaperInitiallySubmitted: equal('task.paper.publishingState',
                                   'initially_submitted'),

  cannotRegisterDecision: or('hasNoLetter',
                             'hasNoVerdict',
                             'isTaskCompleted'),
  actions: {
    registerDecision() {
      this.busyWhile(
        this.get('initialDecision').register(this.get('task')));
    },

    setInitialDecisionVerdict(decision) {
      this.get('initialDecision').set('verdict', decision);
    }
  }
});
