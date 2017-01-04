import Ember from 'ember';
import FakeCanService from '../../../helpers/fake-can-service';
import hbs from 'htmlbars-inline-precompile';
import { make, manualSetup }  from 'ember-data-factory-guy';
import { moduleForComponent, test } from 'ember-qunit';

moduleForComponent('task/front-matter-reviewer-report-task', 'Integration | Component | front matter reviewer report task', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    this.task = make('front-matter-reviewer-report-task', 'with_questions', 'with_paper_and_journal');
    this.can = FakeCanService.create();
    this.register('service:can', this.can.asService());
  }
});

test('Readonly mode: Not able to provide reviewer feedback', function(assert) {
  Ember.run(() => {
    this.task.get('paper').set('decisions', [make('decision', { draft: true })]);
  });
  this.render(hbs`{{front-matter-reviewer-report-task task=task}}`);

  assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=accept]', 'User cannot provide an accept for publication recommendation');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=reject]', 'User cannot provide a reject recommendation');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=major_revision]', 'User cannot provide a major revision recommendation');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=minor_revision]', 'User cannot provide a minor revision recommendation');
  assert.elementNotFound('textarea[name=front_matter_reviewer_report--competing_interests]', 'User cannot provide their competing interests statement');
  assert.elementNotFound('textarea[name=front_matter_reviewer_report--competing_interests]', 'User cannot provide their competing interests statement');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--suitable][type=radio][value=true]', 'User cannot provide yes response to biology suitability');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--suitable][type=radio][value=false]', 'User cannot provide no response to biology suitability');
  assert.elementNotFound('textarea[name=front_matter_reviewer_report--suitable--comment]', 'User cannot provide their review of biology suitability');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--includes_unpublished_data][type=radio][value=true]', 'User cannot provide respond yes to statistical analysis');
  assert.elementNotFound('input[name*=front_matter_reviewer_report--includes_unpublished_data][type=radio][value=false]', 'User cannot provide response no to statistical analysis');
  assert.elementNotFound('textarea[name=front_matter_reviewer_report--includes_unpublished_data--explanation]', 'User cannot provide their review of statistical analysis');
  assert.elementNotFound('textarea[name=front_matter_reviewer_report--additional_comments]', 'User cannot provide additional comments');
  assert.elementNotFound('textarea[name=front_matter_reviewer_report--identity]', 'User cannot provide their identity');
});

test('Edit mode: Providing reviewer feedback', function(assert) {
  this.can.allowPermission('edit', this.task);
  Ember.run(() => {
    this.task.get('paper').set('decisions', [make('decision', { draft: true })]);
  });
  this.render(hbs`{{front-matter-reviewer-report-task task=task}}`);

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
});


