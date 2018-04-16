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
import {
  manualSetup
} from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('review-status', 'Integration | Component | Scheduled Event Status', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    let dueDate = moment('2020-08-19', 'YYYY-MM-DD');
    this.set('dueDate', dueDate);
  }
});

test('renders inactive toggle when event is passive', function(assert) {
  let scheduledEvent = FactoryGuy.make('scheduled-event', {
    name: 'Pre Event',
    dispatchAt: moment(this.get('dueDate')).add(2, 'days'),
    state: 'passive'
  });
  this.set('event', scheduledEvent);
  this.render(hbs `{{scheduled-event-status event=event}}`);
  assert.equal($('.scheduled-event-status input[type=checkbox]').is(':checked'), false);
});

test('renders active toggle when event is active', function(assert) {
  let scheduledEvent = FactoryGuy.make('scheduled-event', {
    name: 'Pre Event',
    dispatchAt: moment(this.get('dueDate')).add(2, 'days'),
    state: 'active'
  });
  this.set('event', scheduledEvent);
  this.render(hbs `{{scheduled-event-status event=event}}`);
  assert.equal($('.scheduled-event-status input[type=checkbox]').is(':checked'), true);
});

test('completed event should be shown as "Sent"', function(assert) {
  let scheduledEvent = FactoryGuy.make('scheduled-event', {
    name: 'Pre Event',
    state: 'completed',
    finished: true,
    dispatchAt: moment(this.get('dueDate')).subtract(2, 'days')
  });
  this.set('event', scheduledEvent);
  this.render(hbs `{{scheduled-event-status event=event}}`);
  assert.textPresent('.scheduled-event-status', 'Sent');
});

test('errored events should be shown as warnings', function(assert) {
  let scheduledEvent = FactoryGuy.make('scheduled-event', {
    name: 'Pre Event',
    state: 'errored',
    finished: true,
    dispatchAt: moment(this.get('dueDate')).subtract(2, 'days')
  });
  this.set('event', scheduledEvent);
  this.render(hbs `{{scheduled-event-status event=event}}`);
  assert.textPresent('.scheduled-event-status', 'Reminder not sent due to a system error');
});

test('inactive events should be shown as not applicable', function(assert) {
  let scheduledEvent = FactoryGuy.make('scheduled-event', {
    name: 'Pre Event',
    state: 'inactive',
    finished: true,
    dispatchAt: moment(this.get('dueDate')).add(2, 'days')
  });
  this.set('event', scheduledEvent);
  this.render(hbs `{{scheduled-event-status event=event}}`);
  assert.textPresent('.scheduled-event-status', 'NA');
});

test('canceled events should be shown as not applicable', function(assert) {
  let scheduledEvent = FactoryGuy.make('scheduled-event', {
    name: 'Pre Event',
    state: 'canceled',
    finished: true,
    dispatchAt: moment(this.get('dueDate')).add(2, 'days')
  });
  this.set('event', scheduledEvent);
  this.render(hbs `{{scheduled-event-status event=event}}`);
  assert.textPresent('.scheduled-event-status', 'NA');
});
