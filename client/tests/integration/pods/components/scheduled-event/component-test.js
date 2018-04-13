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
import { moment } from 'tahi/lib/aperta-moment';

moduleForComponent('review-status', 'Integration | Component | Scheduled Event', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    let dueDate = moment('2020-08-19', 'YYYY-MM-DD');
    this.set('dueDate', dueDate);
  },

  createScheduledEvents(events) {
    return _.map(events, (event) => {
      return FactoryGuy.make('scheduled-event', {
        name: event.name,
        dispatchAt: moment(this.get('dueDate')).add(event.offset, 'days').toDate()
      });
    });
  },
});

function assertScheduledEvents(assertNames, assert) {
  _.each(assertNames, (assertName, index) => {
    assert.textPresent(`.scheduled-event-description:eq(${index})`, assertName);
  });
}

test('renders future scheduled differences properly', function (assert) {
  assert.expect(1);
  const eventData = [
    {name: 'Post Event', offset: 2},
  ];
  const scheduledEvents = this.createScheduledEvents(eventData);
  this.set('events', scheduledEvents);
  this.render(hbs`{{scheduled-events events=events dueDate=dueDate}}`);
  assertScheduledEvents(['2 days after due date'], assert);
});

test('renders past scheduled differences properly', function (assert) {
  assert.expect(1);
  const eventData = [
    {name: 'Pre Event', offset: -2},
  ];
  const scheduledEvents = this.createScheduledEvents(eventData);
  this.set('events', scheduledEvents);
  this.render(hbs`{{scheduled-events events=events dueDate=dueDate}}`);
  assertScheduledEvents(['2 days before due date'], assert);
});

test('renders scheduled events in order', function (assert) {
  assert.expect(3);
  const eventData = [
    {name: 'Post Event', offset: 2},
    {name: 'Pre Event', offset: -2},
    {name: 'Super Post Event', offset: 4}
  ];
  const scheduledEvents = this.createScheduledEvents(eventData);
  this.set('events', scheduledEvents);
  this.render(hbs`{{scheduled-events events=events dueDate=dueDate}}`);
  assertScheduledEvents(
    [
      'Pre Event',
      'Post Event',
      'Super Post Event'
    ], assert );
});
