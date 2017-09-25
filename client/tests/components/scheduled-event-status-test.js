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
