import { make, manualSetup }  from 'ember-data-factory-guy';
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from '../../helpers/fake-can-service';
import Ember from 'ember';

moduleForComponent('reviewer-report-task', 'Integration | Component | reviewer report task', {
  integration: true,

  beforeEach: function () {
    manualSetup(this.container);
  }
});

test('Reviewer report form when the decision is a draft', function(assert) {
  this.task = make('reviewer-report-task', 'with_questions', 'with_paper_and_journal');

  Ember.run(() => {
    this.task.get('paper').set('decisions', [make('decision', { draft: true })]);
  });

  const can = FakeCanService.create();
  can.allowPermission('edit', this.task);
  this.register('service:can', can.asService());

  this.render(hbs`{{reviewer-report-task task=task}}`);

  assert.nElementsFound('textarea', 5);
});

test('Reviewer report form when the decision is not a draft', function(assert) {
  this.task = make('reviewer-report-task', 'with_questions', 'with_paper_and_journal');

  Ember.run(() => {
    this.task.get('paper').set('decisions', [make('decision', { draft: false })]);
  });

  const can = FakeCanService.create();
  can.allowPermission('edit', this.task);
  this.register('service:can', can.asService());

  this.render(hbs`{{reviewer-report-task task=task}}`);

  assert.nElementsFound('textarea', 0);
});

test('History when there are completed decisions', function(assert) {
  this.task = make('reviewer-report-task', 'with_questions', 'with_paper_and_journal');

  const decisions = [
    make('decision', { majorVersion: 0, minorVersion: 0, draft: false }),
    make('decision', { majorVersion: 1, minorVersion: 0, draft: false }),
    make('decision', { majorVersion: null, minorVersion: null, draft: true })
  ];

  Ember.run(() => {
    this.task.get('paper').set('decisions', decisions);
  });

  const can = FakeCanService.create();
  can.allowPermission('edit', this.task);
  this.register('service:can', can.asService());

  this.render(hbs`{{reviewer-report-task task=task}}`);

  assert.nElementsFound('.previous-decision', 2);
});


