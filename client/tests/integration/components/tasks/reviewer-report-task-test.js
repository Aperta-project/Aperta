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
