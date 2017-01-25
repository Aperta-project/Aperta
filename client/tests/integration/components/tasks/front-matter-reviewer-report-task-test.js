import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import { make, manualSetup }  from 'ember-data-factory-guy';
import { moduleForComponent, test } from 'ember-qunit';

moduleForComponent('task/front-matter-reviewer-report-task', 'Integration | Component | Front Matter Reviewer Report Task', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    this.task = make('front-matter-reviewer-report-task', 'with_paper_and_journal');
    this.can = FakeCanService.create();
    this.register('service:can', this.can.asService());
  }
});

function assertEditable(assert) {
  assert.elementFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=accept]', 'User can provide an accept for publication recommendation');
  assert.elementFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=reject]', 'User can provide a reject recommendation');
  assert.elementFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=major_revision]', 'User can provide a major revision recommendation');
  assert.elementFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=minor_revision]', 'User can provide a minor revision recommendation');
  assert.elementFound('textarea[name=front_matter_reviewer_report--competing_interests]', 'User can provide their competing interests statement');
  assert.elementFound('textarea[name=front_matter_reviewer_report--competing_interests]', 'User can provide their competing interests statement');
  assert.elementFound('input[name*=front_matter_reviewer_report--suitable][type=radio][value=true]', 'User can respond yes to biology suitability');
  assert.elementFound('input[name*=front_matter_reviewer_report--suitable][type=radio][value=false]', 'User can respond no to biology suitability');
  assert.elementFound('textarea[name=front_matter_reviewer_report--suitable--comment]', 'User can provide their review of biology suitability');
  assert.elementFound('input[name*=front_matter_reviewer_report--includes_unpublished_data][type=radio][value=true]', 'User can provide respond yes to statistical analysis');
  assert.elementFound('input[name*=front_matter_reviewer_report--includes_unpublished_data][type=radio][value=false]', 'User can provide response no to statistical analysis');
  assert.elementFound('textarea[name=front_matter_reviewer_report--includes_unpublished_data--explanation]', 'User can provide their review of statistical analysis');
  assert.elementFound('textarea[name=front_matter_reviewer_report--additional_comments]', 'User can provide additional comments');
  assert.elementFound('textarea[name=front_matter_reviewer_report--identity]', 'User can provide their identity');
}

function assertNotEditable(assert) {
  assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=accept]', 'User cannot provide an accept for publication recommendation');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=reject]', 'User cannot provide a reject recommendation');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=major_revision]', 'User cannot provide a major revision recommendation');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=minor_revision]', 'User cannot provide a minor revision recommendation');
  assert.elementNotFound('textarea[name=front_matter_reviewer_report--competing_interests]', 'User cannot provide their competing interests statement');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--suitable][type=radio][value=true]', 'User cannot provide yes response to biology suitability');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--suitable][type=radio][value=false]', 'User cannot provide no response to biology suitability');
  assert.elementNotFound('textarea[name=front_matter_reviewer_report--suitable--comment]', 'User cannot provide their review of biology suitability');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--includes_unpublished_data][type=radio][value=true]', 'User cannot provide respond yes to statistical analysis');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--includes_unpublished_data][type=radio][value=false]', 'User cannot provide response no to statistical analysis');
  assert.elementNotFound('textarea[name=front_matter_reviewer_report--includes_unpublished_data--explanation]', 'User cannot provide their review of statistical analysis');
  assert.elementNotFound('textarea[name=front_matter_reviewer_report--additional_comments]', 'User cannot provide additional comments');
  assert.elementNotFound('textarea[name=front_matter_reviewer_report--identity]', 'User cannot provide their identity');
}


test('Readonly mode: Not able to provide reviewer feedback', function(assert) {
  Ember.run(() => {
    let decision = [make('decision', { draft: true })];
    this.task.set('decisions', decision);
    make('reviewer-report', 'with_front_matter_questions', {task: this.task, decision: decision});
  });
  this.render(hbs`{{front-matter-reviewer-report-task task=task}}`);

  assertNotEditable(assert);
});

test('Edit mode: Providing reviewer feedback', function(assert) {
  this.can.allowPermission('edit', this.task);
  Ember.run(() => {
    this.task.set('decisions', [make('decision', { draft: true })]);
  });
  this.render(hbs`{{front-matter-reviewer-report-task task=task}}`);

  assertEditable(assert);
});

test('When the decision is a draft', function(assert) {
  this.can.allowPermission('edit', this.task);
  Ember.run(() => {
    let decision = make('decision', { draft: true });
    let reviewerReports = make('reviewer-report', 'with_front_matter_questions', { task: this.task, decision: decision });
    this.task.set('reviewerReports', [reviewerReports]);
    this.task.set('decisions', [decision]);
  });
  this.render(hbs`{{front-matter-reviewer-report-task task=task}}`);

  assertEditable(assert);
});

test('When the decision is not a draft', function(assert) {
  this.can.allowPermission('edit', this.task);
  Ember.run(() => {
    let decision = make('decision', { draft: false });
    let reviewerReports = make('reviewer-report', 'with_front_matter_questions', { task: this.task, decision: decision });
    this.task.set('reviewerReports', [reviewerReports]);
    this.task.set('decisions', [decision]);
    this.task.set('body', { submitted: true });
  });
  this.render(hbs`{{front-matter-reviewer-report-task task=task}}`);
  assertNotEditable(assert);
});

test('History when there are completed decisions', function(assert) {
  const decisions = [
    make('decision', { majorVersion: 0, minorVersion: 0, draft: false }),
    make('decision', { majorVersion: 1, minorVersion: 0, draft: false }),
    make('decision', { majorVersion: null, minorVersion: null, draft: true })
  ];

  let task = this.task;
  let reviewerReports = decisions.map((decision) => {
    return make('reviewer-report', 'with_front_matter_questions', { task: task, decision: decision });
  });

  Ember.run(() => {
    this.task.set('reviewerReports', reviewerReports);
    this.task.get('paper').set('decisions', decisions);
  });
  this.render(hbs`{{front-matter-reviewer-report-task task=task}}`);
  assert.nElementsFound('.previous-decision', 2);
});

test('That there are the correct nested question answers when there is no draft decision', function(assert) {
  const decisions = [
    make('decision', { majorVersion: 0, minorVersion: 0, draft: false }),
    make('decision', { majorVersion: 1, minorVersion: 0, draft: false })
  ];
  const reviewerReports = [
    make('reviewer-report', 'with_front_matter_questions', { task: this.task, decision: decisions[0] }),
    make('reviewer-report', 'with_front_matter_questions', { task: this.task, decision: decisions[1] })
  ];

  const ident = 'front_matter_reviewer_report--suitable--comment';
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
  this.render(hbs`{{front-matter-reviewer-report-task task=task}}`);
  var decisionId = 2;
  //Answer for first round of review
  const answerSelector = `#collapse-${decisionId} .additional-data .answer-text`;
  assert.textPresent(answerSelector, answers[1].get('value'));
});

