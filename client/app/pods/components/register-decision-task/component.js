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
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import HasBusyStateMixin from 'tahi/mixins/has-busy-state';

const { computed } = Ember;

export default TaskComponent.extend(ValidationErrorsMixin, HasBusyStateMixin, {
  init: function(){
    this._super(...arguments);
    this.get('task.paper.decisions').reload();
  },
  restless: Ember.inject.service('restless'),
  paper: computed.alias('task.paper'),
  submitted: computed.equal('paper.publishingState', 'submitted'),
  uncompleted: computed.equal('task.completed', false),

  publishable: computed.and('submitted', 'uncompleted'),
  nonPublishable: computed.not('publishable'),
  nonPublishableOrUnselected: computed('draftDecision.verdict', 'task.completed', function() {
    return this.get('nonPublishable') || !this.get('draftDecision.verdict');
  }),

  toField: null,
  subjectLine: null,
  isLoading: computed.oneWay('isBusy'),
  revisionNumberDesc: ['revisionNumber:desc'],

  decisions: computed.sort('task.paper.decisions', 'revisionNumberDesc'),
  draftDecision: computed.alias('task.paper.draftDecision'),
  previousDecisions: computed.alias('paper.previousDecisions'),

  verdicts: ['reject', 'major_revision', 'minor_revision', 'accept'],

  onDecisionLetterUpdate: Ember.observer('draftDecision.letter', function() {
    let draftDecision = this.get('draftDecision');
    if (draftDecision && draftDecision.get('hasDirtyAttributes')) {
      Ember.run.debounce(draftDecision, draftDecision.save, 500);
    }
  }),

  actions: {
    updateVerdict(verdict) {
      const decision = this.get('draftDecision');
      decision.set('verdict', verdict);
      decision.save();
    },

    registerDecision() {
      let task = this.get('task');

      this.busyWhile(
        this.get('draftDecision').register(task)
          .then(() => {
            // reload to pick up completed flag on current task and possibly new
            // Response to Reviewers task
            return this.get('task.paper.tasks').reload();
          }).then(() => {
            this.clearAllValidationErrors();
          }).catch((response) => {
            this.displayValidationErrorsFromResponse(response.responseJSON);
          })
      );
    },

    updateTemplate() {
      const templates = this.get('task.letterTemplates')
            .filterBy('category', this.get('draftDecision.verdict'));
      let template;
      if (templates.get('length') === 1) {
        template = templates.get('firstObject').toJSON();
      } else {
        const selectedTemplate = this.get('task')
              .findQuestion('register_decision_questions--selected-template')
              .get('answers.firstObject.value');
        template = templates.findBy('name', selectedTemplate).toJSON();
      }

      const toQuestion = this.get('task').findQuestion('register_decision_questions--to-field');
      const toAnswer = toQuestion.answerForOwner(this.get('task'));
      const to = template.to;
      toAnswer.set('value', to);
      toAnswer.save();

      const subjectQuestion = this.get('task').findQuestion('register_decision_questions--subject-field');
      const subjectAnswer = subjectQuestion.answerForOwner(this.get('task'));
      const subject = template.subject;
      subjectAnswer.set('value', subject);
      subjectAnswer.save();

      const body = template.body;
      this.get('draftDecision').set('letter', body); // will trigger save
    }
  }
});
