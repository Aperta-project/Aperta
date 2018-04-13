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

import {
  moduleForComponent,
  test
} from 'ember-qunit';

import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import { moment } from 'tahi/lib/aperta-moment';

moduleForComponent('review-status', 'Integration | Component | review status', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    this.registry.register('service:can', FakeCanService);

    let dueDate = new Date(2020, 1, 25);
    let paper = FactoryGuy.make('paper');
    let task = FactoryGuy.make('task');
    this.set('report', {
      status: 'not_invited',
      revision: 'v99.0',
      statusDatetime: new Date(2020, 0, 1),
      dueDatetime:{
        dueAt: dueDate,
      },
      originallyDueAt: dueDate,
      task: task
    });
    this.set('report.task.paper', paper);
    let tz = moment.tz.guess();
    this.set('timezone', moment(dueDate).tz(tz).format('z'));
  }
});

test('No due_at unless accepted', function(assert) {
  assert.expect(3);
  let fake = this.container.lookup('service:can');
  let task = this.get('report.task');
  fake.allowPermission('edit_due_date', task);

  this.render(hbs`
    {{reviewer-report-status report=report canEditDueDate=(can 'edit_due_date' report.task)}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    'Not yet invited: This candidate has not been invited to v99.0',
    'Block template shows not invited text'
  );

  assert.textNotPresent('.report-status', 'original due date was');
  this.set('report.status', 'invitation_accepted');

  this.render(hbs`
    {{reviewer-report-status report=report canEditDueDate=(can 'edit_due_date' report.task)}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    `Pending: review of v99.0 due February 25, 2020 12:00 am ${ this.get('timezone') } Change due date Invitation accepted January 1, 2020`,
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
    `Pending: review of v99.0 due February 25, 2020 12:00 am ${ this.get('timezone') } Invitation accepted January 1, 2020`,
    'Block template shows pending text with date'
  );

  this.set('report.status', 'invitation_accepted');

  this.render(hbs`
    {{reviewer-report-status report=report}}
  `);

  assert.equal(
    this.$('.report-status').text().trim().replace(/\s+/g,' '),
    `Pending: review of v99.0 due February 25, 2020 12:00 am ${ this.get('timezone') } Invitation accepted January 1, 2020`,
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
    `Invited: review of v99.0 due February 25, 2020 12:00 am ${ this.get('timezone') } Invitation sent on January 1, 2020`,
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
    `Declined: review of v99.0 due February 25, 2020 12:00 am ${ this.get('timezone') } Invitation declined January 1, 2020`,
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
    `Rescinded: review of v99.0 due February 25, 2020 12:00 am ${ this.get('timezone') } Invitation rescinded January 1, 2020`,
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

test('it only displays originally due date when not equal to due date', function(assert) {
  this.set('report.originallyDueAt', moment(new Date(2020, 4, 12)).format('MMMM DD'));
  this.set('report.status', 'pending');

  this.render(hbs`
    {{reviewer-report-status report=report}}`);

  assert.textPresent(
    '.report-status',
    `original due date was`
  );
});
