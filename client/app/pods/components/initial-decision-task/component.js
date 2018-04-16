/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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

    letterChanged(contents) {
      this.set('initialDecision.letter', contents);
      Ember.run.debounce(this, this.saveDecision, 250);
    },

    setInitialDecisionVerdict(decision) {
      this.get('initialDecision').set('verdict', decision);
      this.saveDecision();
    }
  }
});
