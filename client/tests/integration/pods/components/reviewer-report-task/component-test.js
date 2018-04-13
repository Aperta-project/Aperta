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

import { make, manualSetup }  from 'ember-data-factory-guy';
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import Ember from 'ember';

moduleForComponent('reviewer-report-task', 'Integration | Component | Reviewer Report Task', {
  integration: true,

  beforeEach: function () {
    manualSetup(this.container);
    this.task = make('reviewer-report-task', 'with_paper_and_journal');
    this.can = FakeCanService.create();
    this.register('service:can', this.can.asService());
  }
});

test('When the decision is a draft', function(assert) {
  this.can.allowPermission('edit', this.task);
  Ember.run(() => {
    let decision = make('decision', { draft: true });
    let reviewerReport = make('reviewer-report', 'with_questions',
                              { status: 'pending', task: this.task, decision: decision });
    this.task.set('reviewerReports', [reviewerReport]);
    this.task.set('decisions', [decision]);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  assert.nElementsFound('textarea', 5, 'The report should be editable');
});

test('When the decision is not a draft', function(assert) {
  Ember.run(() => {
    let decision = make('decision', { draft: false });
    let reviewerReport = make('reviewer-report', 'with_questions',
                              { status: 'completed', task: this.task, decision: decision });
    this.task.set('reviewerReports', [reviewerReport]);
    this.task.set('decisions', [decision]);
    this.task.set('body', { submitted: true });
  });
  this.render(hbs`{{reviewer-report-task task=task model=reviewerReport}}`);
  assert.nElementsFound('textarea', 0, 'The report should not be editable');
});

test('When the invitation is declined', function(assert) {
  this.can.allowPermission('edit', this.task);
  Ember.run(() => {
    let decision = make('decision', { draft: true });
    let reviewerReport = make('reviewer-report', 'with_questions',
                              { status: 'invitation_declined', task: this.task, decision: decision });
    this.task.set('reviewerReports', [reviewerReport]);
    this.task.set('decisions', [decision]);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  assert.nElementsFound('textarea', 0, 'The report should not be editable');
  assert.elementNotFound('.reviewer-report-submit-button', 'User cannot submit report');
});

test('When the invitation is rescinded', function(assert) {
  this.can.allowPermission('edit', this.task);
  Ember.run(() => {
    let decision = make('decision', { draft: true });
    let reviewerReport = make('reviewer-report', 'with_questions',
                              { status: 'invitation_rescinded', task: this.task, decision: decision });
    this.task.set('reviewerReports', [reviewerReport]);
    this.task.set('decisions', [decision]);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  assert.nElementsFound('textarea', 0, 'The report should not be editable');
  assert.elementNotFound('.reviewer-report-submit-button', 'User cannot submit report');
});

test('History when there are completed decisions', function(assert) {
  const decisions = [
    make('decision', { majorVersion: null, minorVersion: null, draft: true }),
    make('decision', { majorVersion: 0, minorVersion: 0, draft: false }),
    make('decision', { majorVersion: 1, minorVersion: 0, draft: false })
  ];

  let task = this.task;
  let reviewerReports = decisions.map((decision) => {
    return make('reviewer-report', 'with_questions', { task: task, decision: decision });
  });

  Ember.run(() => {
    this.task.get('paper').set('decisions', decisions);
    this.task.set('reviewerReports', reviewerReports);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  assert.nElementsFound('.previous-decision', 2);
});

test('That there are the correct nested question answers when there is no draft decision', function(assert) {
  const decisions = [
    make('decision', { majorVersion: 0, minorVersion: 0, draft: false }),
    make('decision', { majorVersion: 1, minorVersion: 0, draft: false })
  ];
  const reviewerReports = [
    make('reviewer-report', 'with_questions',
         { status: 'completed', task: this.task, decision: decisions[0] }),
    make('reviewer-report', 'with_questions',
         { status: 'completed', task: this.task, decision: decisions[1] })
  ];

  const ident = 'reviewer_report--comments_for_author';
  const answers = [
    make('nested-question-answer', {
      nestedQuestion: reviewerReports[0].findQuestion(ident),
      value: 'The comments from my first review',
      owner: reviewerReports[0],
      decision: decisions[0]
    }),
    make('nested-question-answer', {
      nestedQuestion: reviewerReports[1].findQuestion(ident),
      value: 'The comments from my second review',
      owner: reviewerReports[1],
      decision: decisions[1]
    })
  ];
  Ember.run(() => {
    this.task.get('paper').set('decisions', decisions);
    this.task.set('reviewerReports', reviewerReports);
    this.task.set('decisions', decisions);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  var decisionId = decisions[1].get('id');
  //Answer for first round of review
  const answerSelector = `#collapse-${decisionId} .question:nth(3) .answer-text`;
  assert.textPresent(answerSelector, answers[1].get('value'));
});

test('allows right permissions to view scheduled events', function (assert) {
  this.can.allowPermission('manage_scheduled_events', this.task);
  const scheduledEvents = [
    make('scheduled-event', { }),
    make('scheduled-event', { })
  ];
  const reviewerReport = make('reviewer-report', 'with_questions',
    { status: 'completed', task: this.task });
  Ember.run(() => {
    this.task.set('reviewerReports', [reviewerReport]);
    this.task.set('reviewerReports.firstObject.dueAt', new Date('2017-08-19'));
    this.task.set('reviewerReports.firstObject.dueDatetime.scheduledEvents', scheduledEvents);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  assert.textPresent('.scheduled-events p', 'Reminders');
});

test('disallow wrong permissions from viewing scheduled events', function (assert) {
  const scheduledEvents = [
    make('scheduled-event', { }),
    make('scheduled-event', { })
  ];
  const reviewerReport = make('reviewer-report', 'with_questions',
    { status: 'completed', task: this.task });
  Ember.run(() => {
    this.task.set('reviewerReports', [reviewerReport]);
    this.task.set('reviewerReports.firstObject.dueAt', new Date('2017-08-19'));
    this.task.set('reviewerReports.firstObject.dueDatetime.scheduledEvents', scheduledEvents);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  assert.textNotPresent('.scheduled-events p', 'Reminders');
});

test('Canceled events appear with minus icon and "NA" text', function (assert) {
  this.can.allowPermission('manage_scheduled_events', this.task);
  const scheduledEvents = [
    make('scheduled-event', {state: 'canceled', finished: true})
  ];
  const reviewerReport = make('reviewer-report', 'with_questions',
    { status: 'completed', task: this.task });
  Ember.run(() => {
    this.task.set('reviewerReports', [reviewerReport]);
    this.task.set('reviewerReports.firstObject.dueAt', new Date('2017-08-19'));
    this.task.set('reviewerReports.firstObject.dueDatetime.scheduledEvents', scheduledEvents);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  assert.elementFound('.scheduled-events i.fa-minus');
  assert.textPresent('.scheduled-events .event-canceled', 'NA');
});
