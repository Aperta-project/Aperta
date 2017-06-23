import {
  moduleForComponent,
  test
} from 'ember-qunit';

import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';

moduleForComponent('review-status', 'Integration | Component | review status', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    this.registry.register('service:can', FakeCanService);

    let paper = FactoryGuy.make('paper');
    let task = FactoryGuy.make('task');
    this.set('report', {
      status: 'not_invited',
      revision: 'v99.0',
      statusDatetime: new Date(2020, 0, 1),
      dueAt: new Date(2020, 1, 25),
      task: task
    });
    this.set('report.task.paper', paper);
  }
});

test('No due_at unless accepted', function(assert) {
  assert.expect(2);
  let fake = this.container.lookup('service:can');
  let paper = this.get('report.task.paper');
  fake.allowPermission('manage_workflow', paper);

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    'Not yet invited: This candidate has not been invited to v99.0',
    'Block template shows not invited text'
  );

  this.set('report.status', 'invitation_accepted');

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    'Pending: review of v99.0 due February 25, 2020 12:00 am Change due date Invitation accepted January 1, 2020',
    'Block template shows not invited text'
  );
});

test('it shows not invited', function(assert) {
  assert.expect(2);

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    'Not yet invited: This candidate has not been invited to v99.0',
    'Block template shows not invited text'
  );

  this.set('report.status', 'invitation_pending');

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    'Not yet invited: This candidate has not been invited to v99.0',
    'Block template shows not invited text'
  );
});

test('it shows pending', function(assert) {
  assert.expect(2);

  this.set('report.status', 'pending');

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    'Pending: review of v99.0 due February 25, 2020 12:00 am Invitation accepted January 1, 2020',
    'Block template shows pending text with date'
  );

  this.set('report.status', 'invitation_accepted');

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    'Pending: review of v99.0 due February 25, 2020 12:00 am Invitation accepted January 1, 2020',
    'Block template shows pending text with date'
  );
});

test('it shows invited', function(assert) {
  assert.expect(1);

  this.set('report.status', 'invitation_invited');

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    'Invited: review of v99.0 due February 25, 2020 12:00 am Invitation sent on January 1, 2020',
    'Block template shows invited text with date'
  );
});

test('it shows declined', function(assert) {
  assert.expect(1);

  this.set('report.status', 'invitation_declined');

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    'Declined: review of v99.0 due February 25, 2020 12:00 am Invitation declined January 1, 2020',
    'Block template shows declined text with date'
  );
});

test('it shows rescinded', function(assert) {
  assert.expect(1);

  this.set('report.status', 'invitation_rescinded');

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    'Rescinded: review of v99.0 due February 25, 2020 12:00 am Invitation rescinded January 1, 2020',
    'Block template shows rescinded text with date'
  );
});

test('it shows completed', function(assert) {
  assert.expect(2);

  this.set('report.status', 'completed');

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  // First line of output
  assert.textPresent(
    '.report-status',
    'v99.0 Review',
    'Block template shows invited text with date'
  );
  // Second line of output
  // Why two assertions? To ignore the whitespace inbetween.
  assert.textPresent(
    '.report-status',
    'Completed January 1, 2020',
    'Block template shows invited text with date'
  );
});
