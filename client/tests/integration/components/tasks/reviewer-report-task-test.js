import { make, manualSetup }  from 'ember-data-factory-guy';
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import Ember from 'ember';

moduleForComponent('reviewer-report-task', 'Integration | Component | reviewer report task', {
  integration: true,

  beforeEach: function () {
    manualSetup(this.container);
    this.task = make('reviewer-report-task', 'with_questions', 'with_paper_and_journal');
    const can = FakeCanService.create();
    can.allowPermission('edit', this.task);
    this.register('service:can', can.asService());
  }
});

test('When the decision is a draft', function(assert) {
  Ember.run(() => {
    this.task.set('decisions', [make('decision', { draft: true })]);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  assert.nElementsFound('textarea', 5, 'The report should be editable');
});

test('When the decision is not a draft', function(assert) {
  Ember.run(() => {
    this.task.set('decisions', [make('decision', { draft: false })]);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  assert.nElementsFound('textarea', 0, 'The report should not be editable');
});

test('History when there are completed decisions', function(assert) {
  const decisions = [
    make('decision', { majorVersion: 0, minorVersion: 0, draft: false }),
    make('decision', { majorVersion: 1, minorVersion: 0, draft: false }),
    make('decision', { majorVersion: null, minorVersion: null, draft: true })
  ];
  Ember.run(() => {
    this.task.set('decisions', decisions);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  assert.nElementsFound('.previous-decision', 2);
});

test('That there are the correct nested question answers when there is no draft decision', function(assert) {
  const decisions = [
    make('decision', { majorVersion: 0, minorVersion: 0, draft: false }),
    make('decision', { majorVersion: 1, minorVersion: 0, draft: false })
  ];
  const ident = 'reviewer_report--comments_for_author';
  const answers = [
    make('nested-question-answer', {
      nestedQuestion: this.task.findQuestion(ident),
      value: 'The comments from my first review',
      owner: this.task,
      decision: decisions[0]
    }),
    make('nested-question-answer', {
      nestedQuestion: this.task.findQuestion(ident),
      value: 'The comments from my second review',
      owner: this.task,
      decision: decisions[1]
    })
  ];
  Ember.run(() => {
    this.task.set('decisions', decisions);
  });
  this.render(hbs`{{reviewer-report-task task=task}}`);
  const answerSelector = `.most-recent-review .${ident}-nested-question .answer-text`;
  assert.textPresent(answerSelector, answers[1].get('value'));
});


