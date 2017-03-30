import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('review-status', 'Integration | Component | review status', {
  integration: true,

  beforeEach() {
    this.set('report', {
      status: 'not_invited',
      revision: 'v99.0',
      statusDatetime: new Date(2020, 0, 1)
    });
  }
});

test('it shows not invited', function(assert) {
  assert.expect(2);

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim(),
    'Not yet invited: This candidate has not been invited to v99.0',
    'Block template shows not invited text'
  );

  this.set('report.status', 'invitation_pending');

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim(),
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
    this.$('.report-status').text().trim(),
    'Pending: Invitation to review v99.0 accepted January 1, 2020',
    'Block template shows pending text with date'
  );

  this.set('report.status', 'invitation_accepted');

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim(),
    'Pending: Invitation to review v99.0 accepted January 1, 2020',
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
    this.$('.report-status').text().trim(),
    'Invited: Invitation to review v99.0 sent on January 1, 2020',
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
    this.$('.report-status').text().trim(),
    'Declined: Invitation to review v99.0 declined January 1, 2020',
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
    this.$('.report-status').text().trim(),
    'Rescinded: Invitation to review v99.0 rescinded January 1, 2020',
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
