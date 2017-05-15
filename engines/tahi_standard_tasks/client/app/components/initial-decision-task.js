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
  initialDecisionsAscending: computed.filterBy(
    'task.paper.sortedDecisions', 'initial', true),
  initialDecisions: computed('initialDecisionsAscending.[]', function() {
    return this.get('initialDecisionsAscending').reverse();
  }),
  initialDecision: computed.alias('task.paper.initialDecision'),
  nonPublishable: not('publishable'),
  hasNoLetter: empty('initialDecision.letter'),
  hasNoVerdict: none('initialDecision.verdict'),
  isPaperInitiallySubmitted: equal('task.paper.publishingState',
                                   'initially_submitted'),

  cannotRegisterDecision: or('hasNoLetter',
                             'hasNoVerdict',
                             'isTaskCompleted'),

  saveDecision() {
    return this.get('initialDecision').save();
  },

  actions: {
    registerDecision() {
      const task = this.get('task');

      this.busyWhile(
        this.get('initialDecision').register(task)
          .then(() => {
            // reload to pick up completed flag on current task
            return task.reload();
          })
      );
    },

    letterChanged() {
      Ember.run.debounce(this, this.saveDecision, 250);
    },

    setInitialDecisionVerdict(decision) {
      this.get('initialDecision').set('verdict', decision);
      this.saveDecision();
    }
  }
});
